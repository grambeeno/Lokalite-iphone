//
//  Business+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Business+GeneralHelpers.h"

#import "Location.h"
#import "Location+GeneralHelpers.h"

#import "Category.h"
#import "Category+GeneralHelpers.h"

#import "LokaliteDownloadSource.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface Business ()

#pragma mark - Parsing helpers

- (void)setImageUrlsFromJsonData:(NSDictionary *)json;

@end


@implementation Business (GeneralHelpers)

#pragma mark - NSManagedObject implementation

- (void)prepareForDeletion
{
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

#pragma mark - Lifecycle

- (BOOL)deleteIfAppropriate
{
    if ([[self events] count] == 0) {
        [[self managedObjectContext] deleteObject:self];
        return YES;
    }

    return NO;
}

#pragma mark - Creating and finding businesses

+ (id)createOrUpdateBusinessFromJsonData:(NSDictionary *)businessData
                          downloadSource:(LokaliteDownloadSource *)source
                               inContext:(NSManagedObjectContext *)context
{
    NSNumber *businessId = [businessData objectForKey:@"id"];
    Business *business =
        [Business existingOrNewInstanceWithIdentifier:businessId
                                            inContext:context];

    [business addDownloadSourcesObject:source];

    NSString *name = [businessData objectForKey:@"name"];
    [business setValueIfNecessary:name forKey:@"name"];

    NSString *phone = [businessData objectForKey:@"phone"];
    phone = [phone length] ? phone : nil;  // HACK
    [business setValueIfNecessary:phone forKey:@"phone"];

    NSString *summary = [businessData objectForKey:@"description"];
    [business setValueIfNecessary:summary forKey:@"summary"];

    NSString *url = [businessData objectForKey:@"url"];
    url = [url length] ? url : nil;  // HACK
    [business setValueIfNecessary:url forKey:@"url"];

    [business setImageUrlsFromJsonData:businessData];

    NSDictionary *locationData = [businessData objectForKey:@"location"];
    Location *location =
        [Location existingOrNewLocationFromJsonData:locationData
                                     downloadSource:source
                                          inContext:context];
    [business setLocation:location];

    NSArray *categoryData = [businessData objectForKey:@"categories"];
    NSArray *categories =
        [Category existingOrNewCategoriesFromJsonData:categoryData
                                       downloadSource:source
                                            inContext:context];
    [business removeCategories:[business categories]];
    [business addCategories:[NSSet setWithArray:categories]];

    return business;
}

+ (NSArray *)businessObjectsFromJsonObjects:(NSDictionary *)jsonObjects
                             downloadSource:(LokaliteDownloadSource *)source
                                withContext:(NSManagedObjectContext *)context
{
    NSArray *objs = [[jsonObjects objectForKey:@"data"] objectForKey:@"list"];

    NSMutableArray *places = [NSMutableArray arrayWithCapacity:[objs count]];
    [objs enumerateObjectsUsingBlock:
     ^(NSDictionary *placeData, NSUInteger idx, BOOL *stop) {
         Business *business =
            [Business createOrUpdateBusinessFromJsonData:placeData
                                          downloadSource:source
                                               inContext:context];
         [places addObject:business];
     }];

    return places;
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

#pragma mark - Searching

+ (NSPredicate *)predicateForSearchString:(NSString *)searchString
{
    NSArray *keyPaths = [NSArray arrayWithObject:@"name"];

    return [NSPredicate standardSearchPredicateForSearchString:searchString
                                             attributeKeyPaths:keyPaths];
}

@end


@implementation Business (ConvenienceMethods)

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

- (NSURL *)phoneUrl
{
    NSString *s = [NSString stringWithFormat:@"tel://%@", [self phone]];
    return [NSURL URLWithString:s];
}

@end




@implementation Business (GeoHelpers)

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
    NSString *description = nil;
    if (location) {
        CLLocation *myLocation = [self locationInstance];
        CLLocationDistance d = [location distanceFromLocation:myLocation];
        distance = [NSNumber numberWithDouble:d];

        description = [DistanceFormatter sectionDescriptionForDistance:d];
    }

    [self setDistance:distance];
    [self setDistanceDescription:description];
}

@end


@implementation Business (TableViewHelpers)

+ (NSArray *)nameTableViewSortDescriptors
{
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                         ascending:YES];
    return [NSArray arrayWithObject:sd];
}

+ (NSArray *)locationTableViewSortDescriptors
{
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"distance"
                                                          ascending:YES];

    return [NSArray arrayWithObject:sd1];
}

@end

