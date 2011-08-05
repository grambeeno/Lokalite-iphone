//
//  Venue+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Venue+GeneralHelpers.h"

#import "LokaliteDownloadSource.h"

#import "Location.h"
#import "Location+GeneralHelpers.h"

#import "NSManagedObject+GeneralHelpers.h"

@implementation Venue (GeneralHelpers)

+ (id)existingOrNewVenueFromJsonData:(NSDictionary *)jsonData
                      downloadSource:(LokaliteDownloadSource *)source
                           inContext:(NSManagedObjectContext *)context
{
    NSNumber *venueId = [jsonData objectForKey:@"id"];
    Venue *venue = [self existingOrNewInstanceWithIdentifier:venueId
                                                   inContext:context];
    [venue addDownloadSourcesObject:source];

    NSDictionary *locationData = [jsonData objectForKey:@"location"];
    Location *location =
        [Location existingOrNewLocationFromJsonData:locationData
                                     downloadSource:source
                                          inContext:context];
    [venue setLocation:location];

    return venue;
}

#pragma mark - NSManagedObject implementation

- (void)prepareForDeletion
{
    NSManagedObjectContext *context = [self managedObjectContext];

    Location *location = [[self location] retain];
    [self setLocation:nil];

    if ([[location venues] count] == 0)
        [context deleteObject:location];

    [location release], location = nil;

    [super prepareForDeletion];
}

@end
