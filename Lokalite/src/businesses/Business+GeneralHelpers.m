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

#import "LokaliteObjectBuilder.h"

#import "SDKAdditions.h"

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
    [business setValueIfNecessary:phone forKey:@"phone"];

    NSString *address = [businessData objectForKey:@"address"];
    [business setValueIfNecessary:address forKey:@"address"];

    NSString *summary = [businessData objectForKey:@"description"];
    [business setValueIfNecessary:summary forKey:@"summary"];

    NSString *url = [businessData objectForKey:@"url"];
    [business setValueIfNecessary:url forKey:@"url"];

    NSString *email = [businessData objectForKey:@"email"];
    [business setValueIfNecessary:email forKey:@"email"];

    id status = [businessData objectForKey:@"status"];
    NSString *statusString = nil;
    if ([status isKindOfClass:[NSString class]])
        statusString = status;
    else if ([status isKindOfClass:[NSDictionary class]]) {
        NSDictionary *d = (NSDictionary *) status;
        statusString = [d objectForKey:@"content"];
    }
    [business setValueIfNecessary:statusString forKey:@"status"];

    NSDictionary *imageData =
        [[businessData objectForKey:@"image"] objectForKey:@"image"];
    if (imageData) {
        NSString *url = [imageData objectForKey:@"url"];
        if ([business setValueIfNecessary:url forKey:@"imageUrl"])
            [business setImageData:nil];
    }

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

    NSMutableArray *places =
        [NSMutableArray arrayWithCapacity:[jsonObjects count]];
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

#pragma mark - Searching

+ (NSPredicate *)predicateForSearchString:(NSString *)searchString
{
    NSArray *keyPaths = [NSArray arrayWithObject:@"name"];

    return [NSPredicate standardSearchPredicateForSearchString:searchString
                                             attributeKeyPaths:keyPaths];
}

@end


@implementation Business (ConvenienceMethods)

- (UIImage *)image
{
    NSData *data = [self imageData];
    return data ? [UIImage imageWithData:data] : nil;
}

- (NSURL *)fullImageUrl
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    NSString *urlPath = [self imageUrl];
    return [baseUrl URLByAppendingPathComponent:urlPath];
}

- (NSURL *)addressUrl
{
    NSStringEncoding encoding = NSUTF8StringEncoding;
    NSString *s =
        [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",
         [[self address] stringByAddingPercentEscapesUsingEncoding:encoding]];

    return [NSURL URLWithString:s];
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

@end
