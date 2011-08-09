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

@implementation Location (GeneralHelpers)

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

    NSNumber *lat = [jsonData objectForKey:@"lat"];
    NSNumber *lon = [jsonData objectForKey:@"lng"];
    [location setValueIfNecessary:lat forKey:@"latitude"];
    [location setValueIfNecessary:lon forKey:@"longitude"];

    return location;
}

@end
