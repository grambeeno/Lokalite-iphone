//
//  LokaliteTrendingEventStream.m
//  Lokalite
//
//  Created by John Debay on 8/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteTrendingEventStream.h"

#import "LokaliteService.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation LokaliteTrendingEventStream

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service = [self service];
    [service fetchEventsWithCategory:nil
                            fromPage:[self pagesFetched] + 1
                      objectsPerPage:[self objectsPerPage]
                     responseHandler:
     ^(NSHTTPURLResponse *response, NSDictionary *jsonObjects, NSError *error) {
         NSArray *parsedObjects = nil;
         if (jsonObjects) {
             parsedObjects =
                [Event eventObjectsFromJsonObjects:jsonObjects
                                    downloadSource:[self downloadSource]
                                       withContext:[self context]];
         }

         handler(parsedObjects, error);
     }];
}

@end


@implementation LokaliteTrendingEventStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context
{
    NSString *name = @"events?category=trending";
    return [self streamWithDownloadSourceName:name context:context];
}

@end

