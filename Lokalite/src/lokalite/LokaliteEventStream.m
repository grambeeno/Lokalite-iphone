//
//  LokaliteEventStream.m
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteEventStream.h"
#import "LokaliteService.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation LokaliteEventStream

#pragma mark - LokaliteStream implementation

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service = [self service];
    [service fetchEventsWithCategory:nil
                        nearLocation:[self location]
                            fromPage:[self pagesFetched] + 1
                      objectsPerPage:[self objectsPerPage]
                     responseHandler:
     ^(NSHTTPURLResponse *response, NSDictionary *jsonObjects, NSError *error) {
         NSArray *parsedObjects = nil;
         if (jsonObjects)
             parsedObjects =
                [Event eventObjectsFromJsonObjects:jsonObjects
                                    downloadSource:[self downloadSource]
                                       withContext:[self context]];

         handler(parsedObjects, error);
     }];
}


@end


@implementation LokaliteEventStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context
{
    NSString *name = @"events";
    return [self streamWithDownloadSourceName:name context:context];
}

@end
