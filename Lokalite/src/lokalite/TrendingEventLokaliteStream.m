//
//  LokaliteTrendingEventStream.m
//  Lokalite
//
//  Created by John Debay on 8/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TrendingEventLokaliteStream.h"

#import "LokaliteService.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation TrendingEventLokaliteStream

- (void)fetchNextBatchOfObjectsFromPage:(NSInteger)page
                        responseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service = [self service];
    [service fetchEventsWithCategory:@"trending"
                            fromPage:page
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


@implementation TrendingEventLokaliteStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context
{
    NSString *name = @"events?order=trending";
    return [self streamWithDownloadSourceName:name context:context];
}

@end

