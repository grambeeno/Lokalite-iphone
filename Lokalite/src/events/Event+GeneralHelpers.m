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

#import "Venue.h"
#import "Venue+GeneralHelpers.h"

#import "Category.h"
#import "Category+GeneralHelpers.h"

#import "SDKAdditions.h"

@implementation Event (GeneralHelpers)

+ (id)eventWithId:(NSNumber *)eventId inContext:(NSManagedObjectContext *)moc
{
    return [self instanceWithIdentifier:eventId inContext:moc];
}

+ (NSArray *)eventObjectsFromJsonObjects:(NSDictionary *)jsonObjects
                             withContext:(NSManagedObjectContext *)context
{
    NSArray *objs = [[jsonObjects objectForKey:@"data"] objectForKey:@"list"];
    NSArray *events =
        [LokaliteObjectBuilder createOrUpdateEventsInJsonArray:objs
                                                     inContext:context];
    return events;
}

+ (NSArray *)replaceObjectsFromJsonObjects:(NSDictionary *)jsonObjects
                                 inContext:(NSManagedObjectContext *)context
{
    NSArray *objs = [[jsonObjects objectForKey:@"data"] objectForKey:@"list"];
    NSArray *events =
        [LokaliteObjectBuilder createOrUpdateEventsInJsonArray:objs
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

+ (id)createOrUpdateEventFromJsonData:(NSDictionary *)eventData
                            inContext:(NSManagedObjectContext *)context
{
    NSDictionary *bData = [eventData objectForKey:@"organization"];
    Business *business = [Business createOrUpdateBusinessFromJsonData:bData
                                                            inContext:context];

    NSNumber *eventId = [eventData objectForKey:@"id"];
    NSString *name = [eventData objectForKey:@"name"];

    Event *event = [self eventWithId:eventId inContext:context];
    if (event)
        NSLog(@"Event exists: %@: %@", eventId, name);
    else {
        NSLog(@"Creating new event: %@: %@", eventId, name);
        event = [self createInstanceInContext:context];
        [event setIdentifier:eventId];
    }

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

    NSDictionary *imageData =
        [[eventData objectForKey:@"image"] objectForKey:@"image"];
    if (imageData) {
        NSString *url = [imageData objectForKey:@"url"];
        if ([event setValueIfNecessary:url forKey:@"imageUrl"])
            [event setImageData:nil];
    }

    NSNumber *featured = [eventData objectForKey:@"featured?"];
    [event setValueIfNecessary:featured forKey:@"featured"];

    NSNumber *trended = [eventData objectForKey:@"trended?"];
    [event setValueIfNecessary:trended forKey:@"trended"];
    NSLog(@"%@ trended: %@ (%@)", [event name], [event trended], trended);

    NSDictionary *venueData = [eventData objectForKey:@"venue"];
    Venue *venue = [Venue existingOrNewVenueFromJsonData:venueData
                                               inContext:context];
    [event setVenue:venue];

    NSDictionary *categoryData = [eventData objectForKey:@"category"];
    Category *category =
        [Category existingOrNewCategoryFromJsonData:categoryData
                                          inContext:context];
    [event setCategory:category];

    return event;
}

#pragma mark - Object lifecycle

- (void)prepareForDeletion
{
    NSManagedObjectContext *context = [self managedObjectContext];

    Business *business = [[self business] retain];
    [self setBusiness:nil];
    if ([[business events] count] == 0)
        [context deleteObject:business];

    Venue *venue = [[self venue] retain];
    [self setVenue:nil];
    if ([[venue events] count] == 0)
        [context deleteObject:venue];

    [business release], business = nil;
    [venue release], venue = nil;

    [super prepareForDeletion];
}

@end



#import <CoreLocation/CoreLocation.h>
#import "Venue.h"
#import "Location.h"

#import "NSPredicate+GeneralHelpers.h"

@implementation Event (ConvenienceMethods)

- (BOOL)isTrended
{
    NSNumber *trended = [self trended];
    return trended ? [trended boolValue] : NO;
}

- (NSURL *)fullImageUrl
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    NSString *urlPath = [self imageUrl];
    return [baseUrl URLByAppendingPathComponent:urlPath];
}

- (UIImage *)image
{
    NSData *data = [self imageData];
    return data ? [UIImage imageWithData:data] : nil;
}

- (CLLocation *)location
{
    Location *location = [[self venue] location];
    NSNumber *lat = [location latitude], *lon = [location longitude];
    CLLocation *loc = [[CLLocation alloc] initWithLatitude:[lat floatValue]
                                                 longitude:[lon floatValue]];

    return [loc autorelease];
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

@end

