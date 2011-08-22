//
//  Event+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Event+GeneralHelpers.h"

#import "LokaliteObjectBuilder.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"

#import "Category.h"
#import "Category+GeneralHelpers.h"

#import "Location.h"
#import "Location+GeneralHelpers.h"

#import "LokaliteDownloadSource.h"
#import "LokaliteDownloadSource+GeneralHelpers.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface Event ()

#pragma mark - Parsing helpers

- (void)setImageUrlsFromJsonData:(NSDictionary *)json;

@end


@implementation Event (GeneralHelpers)

+ (id)eventWithId:(NSNumber *)eventId inContext:(NSManagedObjectContext *)moc
{
    return [self instanceWithIdentifier:eventId inContext:moc];
}

+ (NSArray *)eventObjectsFromJsonObjects:(NSDictionary *)jsonObjects
                          downloadSource:(LokaliteDownloadSource *)source
                             withContext:(NSManagedObjectContext *)context
{
    NSArray *objs = [[jsonObjects objectForKey:@"data"] objectForKey:@"list"];
    NSArray *events = [self createOrUpdateEventsFromJsonArray:objs
                                               downloadSource:source
                                                    inContext:context];

    return events;
}

+ (NSArray *)createOrUpdateEventsFromJsonArray:(NSArray *)jsonObjects
                                downloadSource:(LokaliteDownloadSource *)source
                                     inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *events =
        [NSMutableArray arrayWithCapacity:[jsonObjects count]];
    [jsonObjects enumerateObjectsUsingBlock:
     ^(NSDictionary *eventData, NSUInteger idx, BOOL *stop) {
         Event *event = [Event createOrUpdateEventFromJsonData:eventData
                                                downloadSource:source
                                                     inContext:context];
         [events addObject:event];
     }];

    return events;
}

+ (id)createOrUpdateEventFromJsonData:(NSDictionary *)eventData
                       downloadSource:(LokaliteDownloadSource *)source
                            inContext:(NSManagedObjectContext *)context
{
    NSDictionary *bData = [eventData objectForKey:@"organization"];
    Business *business = [Business createOrUpdateBusinessFromJsonData:bData
                                                       downloadSource:source
                                                            inContext:context];

    NSNumber *eventId = [eventData objectForKey:@"id"];
    NSString *name = [eventData objectForKey:@"name"];

    Event *event = [self existingOrNewInstanceWithIdentifier:eventId
                                                   inContext:context];

    [event addDownloadSourcesObject:source];
    [event setBusiness:business];

    [event setValueIfNecessary:name forKey:@"name"];

    NSString *startString = [eventData objectForKey:@"starts_at"];
    NSDate *startDate = [NSDate dateFromLokaliteServerString:startString];
    [event setValueIfNecessary:startDate forKey:@"startDate"];

    NSString *endString = [eventData objectForKey:@"ends_at"];
    NSDate *endDate = [NSDate dateFromLokaliteServerString:endString];
    [event setValueIfNecessary:endDate forKey:@"endDate"];

    NSString *summary = [eventData objectForKey:@"description"];
    [event setValueIfNecessary:summary forKey:@"summary"];

    NSNumber *featured = [eventData objectForKey:@"featured?"];
    [event setValueIfNecessary:featured forKey:@"featured"];

    /*
     * Removing until we are loading trending status for events from the server.
     * Right now we're managing it entirely on the device.
     */
    /*
    NSNumber *trended = [eventData objectForKey:@"trended?"];
    [event setValueIfNecessary:trended forKey:@"trended"];
     */

    NSNumber *usersCount = [eventData objectForKey:@"users_count"];
    [event setValueIfNecessary:usersCount forKey:@"usersCount"];

    [event setImageUrlsFromJsonData:eventData];

    NSDictionary *locationData = [eventData objectForKey:@"location"];
    Location *location =
        [Location existingOrNewLocationFromJsonData:locationData
                                     downloadSource:source
                                          inContext:context];
    [event setLocation:location];

    NSArray *categoryData = [eventData objectForKey:@"categories"];
    NSArray *categories =
        [Category existingOrNewCategoriesFromJsonData:categoryData
                                       downloadSource:source
                                            inContext:context];
    [event removeCategories:[event categories]];
    [event setCategories:[NSSet setWithArray:categories]];

    return event;
}

+ (NSArray *)replaceObjectsFromJsonObjects:(NSDictionary *)jsonObjects
                            downloadSource:(LokaliteDownloadSource *)source
                                 inContext:(NSManagedObjectContext *)context
{
    NSArray *objs = [[jsonObjects objectForKey:@"data"] objectForKey:@"list"];
    NSArray *events = [self createOrUpdateEventsFromJsonArray:objs
                                               downloadSource:source
                                                    inContext:context];

    NSArray *all = [Event findAllInContext:context];
    [LokaliteObjectBuilder replaceLokaliteObjects:all
                                      withObjects:events
                                  usingValueOfKey:@"identifier"
                                 remainingHandler:
     ^(Event *remainingObject) {
         [context deleteObject:remainingObject];
     }];

    return events;
}

+ (NSPredicate *)predicateForSearchString:(NSString *)searchString
                            includeEvents:(BOOL)includeEvents
                        includeBusinesses:(BOOL)includeBusinesses
{
    NSMutableArray *attributes = [NSMutableArray array];

    if (includeEvents) {
        [attributes addObjectsFromArray:
         [NSArray arrayWithObjects:@"name", /*@"summary",*/ nil]];
        NSLog(@"including events");
    }

    if (includeBusinesses) {
        [attributes addObjectsFromArray:
         [NSArray arrayWithObjects:@"business.name", /*@"business.status",
          @"business.summary",*/ nil]];
        NSLog(@"including businesses");
    }

    return [NSPredicate standardSearchPredicateForSearchString:searchString
                                             attributeKeyPaths:attributes];
}

#pragma mark - Parsing helpers

- (void)setImageUrlsFromJsonData:(NSDictionary *)json
{
    static NSDictionary *mappings = nil;
    if (!mappings) {
        mappings =
            [[NSDictionary alloc] initWithObjectsAndKeys:
             @"fullImage", @"image_full",
             @"largeImage", @"image_large",
             @"mediumImage", @"image_medium",
             @"smallImage", @"image_small",
             @"thumbnailImage", @"image_thumb", nil];
    }

    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    [mappings enumerateKeysAndObjectsUsingBlock:
     ^(NSString *jsonKey, NSString *eventKey, BOOL *stop) {
         NSString *urlKey = [eventKey stringByAppendingString:@"Url"];

         NSString *urlFragment = [json objectForKey:jsonKey];
         NSString *url =
            [[baseUrl URLByAppendingPathComponent:urlFragment] absoluteString];
         if ([self setValueIfNecessary:url forKey:urlKey]) {
             NSString *dataKey = [eventKey stringByAppendingString:@"Data"];
             [self setValue:nil forKey:dataKey];
         }
    }];
}

#pragma mark - Object lifecycle

- (void)prepareForDeletion
{
    Business *business = [[self business] retain];
    [self setBusiness:nil];
    [business deleteIfAppropriate];
    [business release], business = nil;

    Location *location = [[self location] retain];
    [self setLocation:nil];
    [location deleteIfAppropriate];
    [location release], location = nil;

    NSSet *categories = [[self categories] retain];
    [self setCategories:nil];
    [categories makeObjectsPerformSelector:@selector(deleteIfAppropriate)];
    [categories release], categories = nil;

    [super prepareForDeletion];
}

@end



#import <CoreLocation/CoreLocation.h>
#import "Location.h"

@implementation Event (ConvenienceMethods)

- (NSString *)dateStringDescription
{
    return [NSString textRangeWithStartDate:[self startDate]
                                    endDate:[self endDate]];
}

- (BOOL)isTrended
{
    NSNumber *trended = [self trended];
    return trended ? [trended boolValue] : NO;
}

- (BOOL)isFeatured
{
    NSNumber *featured = [self featured];
    return [featured boolValue];
}

- (NSURL *)lokaliteUrl
{
    NSURL *url = [[UIApplication sharedApplication] baseLokaliteUrl];
    url = [url URLByAppendingPathComponent:@"event"];

    return [url URLByAppendingPathComponent:[[self identifier] description]];
}

- (NSData *)standardImageData
{
    return [self fullImageData];
}

- (void)setStandardImageData:(NSData *)data
{
    [self setFullImageData:data];
}

- (UIImage *)standardImage
{
    NSData *data = [self fullImageData];
    return data ? [UIImage imageWithData:data] : nil;
}

- (NSString *)standardImageUrl
{
    return [self fullImageUrl];
}

- (void)trendEvent:(BOOL)trend
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSString *sourceName = @"trended";
    LokaliteDownloadSource *source =
        [LokaliteDownloadSource downloadSourceWithName:sourceName
                                             inContext:context
                                     createIfNecessary:YES];

    if (trend) {
        [source setLastUpdated:[NSDate distantFuture]];
        [self addDownloadSourcesObject:source];
    } else {
        [self removeDownloadSourcesObject:source];
        if ([[source lokaliteObjects] count] == 0)
            // safe to delete the download source
            [context deleteObject:source];
    }

    [self setTrended:[NSNumber numberWithBool:trend]];
    NSLog(@"Event %@ has been %@ by the user", [self identifier],
          trend ? @"trended" : @"untrended");
}

@end


@implementation Event (GeoHelpers)

- (CLLocation *)locationInstance
{
    Location *location = [self location];
    NSNumber *lat = [location latitude], *lon = [location longitude];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[lat floatValue]
                                                 longitude:[lon floatValue]];

    return [loc autorelease];
}

- (void)updateWithDistanceFromLocation:(CLLocation *)location
{
    NSNumber *distance = nil;
    if (location) {
        CLLocation *myLocation = [self locationInstance];
        CLLocationDistance d = [location distanceFromLocation:myLocation];
        distance = [NSNumber numberWithDouble:d];
    }

    [self setDistance:distance];
}

@end


@implementation Event (ViewControllerHelpers)

+ (NSArray *)dateTableViewSortDescriptors
{
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"startDate"
                                                          ascending:YES];
    NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                          ascending:YES];

    return [NSArray arrayWithObjects:sd1, sd2, nil];
}

+ (NSArray *)locationTableViewSortDescriptors
{
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"distance"
                                                          ascending:YES];

    return [NSArray arrayWithObject:sd1];
}

@end

