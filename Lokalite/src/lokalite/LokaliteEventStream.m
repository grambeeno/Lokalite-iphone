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
    LokaliteService *service =
        [[LokaliteService alloc] initWithBaseUrl:[self baseUrl]];
    [service fetchEventsWithCategory:@""
                     responseHandler:
     ^(NSDictionary *jsonObjects, NSError *error) {
         NSArray *parsedObjects = nil;
         if (jsonObjects)
             parsedObjects = [Event eventObjectsFromJsonObjects:jsonObjects
                                                    withContext:[self context]];

         handler(parsedObjects, error);

         [service release];
     }];
}


@end
