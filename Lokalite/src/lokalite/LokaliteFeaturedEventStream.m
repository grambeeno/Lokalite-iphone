//
//  LokaliteFeaturedEventStream.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteFeaturedEventStream.h"

#import "LokaliteService.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation LokaliteFeaturedEventStream

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service = [self service];

    [service fetchEventsWithCategory:@"featured"
                            fromPage:[self pagesFetched] + 1
                     responseHandler:
     ^(NSHTTPURLResponse *response, NSDictionary *jsonObjects, NSError *error) {
         NSArray *parsedObjects = nil;
         if (jsonObjects) {
             parsedObjects =
                [Event eventObjectsFromJsonObjects:jsonObjects
                                    downloadSource:[self downloadSource]
                                       withContext:[self context]];

             NSNumber *yes = [NSNumber numberWithBool:YES];
             [parsedObjects makeObjectsPerformSelector:@selector(setFeatured:)
                                            withObject:yes];
         }

         handler(parsedObjects, error);
     }];
}

@end


@implementation LokaliteFeaturedEventStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context
{
    NSString *name = @"events?category=featured";
    return [self streamWithDownloadSourceName:name context:context];
}

@end
