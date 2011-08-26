//
//  Location+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Location+GeneralHelpers.h"

#import "LokaliteDownloadSource.h"

#import "NSObject+GeneralHelpers.h"
#import "NSManagedObject+GeneralHelpers.h"

#import <CoreLocation/CoreLocation.h>

@implementation Location (GeneralHelpers)

#pragma mark - Lifecycle

- (BOOL)deleteIfAppropriate
{
    if ([[self events] count] == 0 && [[self businesses] count] == 0) {
        [[self managedObjectContext] deleteObject:self];
        return YES;
    }

    return NO;
}

#pragma mark - Convenience methods

- (NSURL *)addressUrl
{
    NSString *encodedString =
        [[self formattedAddress]
         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *s =
        [NSString stringWithFormat:@"http://maps.google.com/maps?q=%@",
         encodedString];

    return [NSURL URLWithString:s];
}

- (NSURL *)urlForDirectionsFromLocation:(CLLocation *)location
{
    NSString *srcString =
        location ?
        [NSString stringWithFormat:@"%f,%f", [location coordinate].latitude,
         [location coordinate].longitude] :
        @"";

    NSString *destString =
        [[self formattedAddress]
         stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *s =
        [NSString stringWithFormat:
         @"http://maps.google.com/maps?saddr=%@&daddr=%@", srcString,
         destString];

    return [NSURL URLWithString:s];
}


#pragma mark - Creating and finding instances

+ (id)existingOrNewLocationFromJsonData:(NSDictionary *)jsonData
                         downloadSource:(LokaliteDownloadSource *)source
                              inContext:(NSManagedObjectContext *)context
{
    NSNumber *identifier = [jsonData objectForKey:@"id"];
    Location *location = [self existingOrNewInstanceWithIdentifier:identifier
                                                         inContext:context];
    [location addDownloadSourcesObject:source];

    [location setValueIfNecessary:[jsonData objectForKey:@"formatted_address"]
                                                  forKey:@"formattedAddress"];

    NSString *lat = [jsonData objectForKey:@"latitude"];
    NSString *lon = [jsonData objectForKey:@"longitude"];

    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    [location setValueIfNecessary:[f numberFromString:lat] forKey:@"latitude"];
    [location setValueIfNecessary:[f numberFromString:lon] forKey:@"longitude"];
    [f release], f = nil;

    return location;
}

@end
