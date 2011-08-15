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
    [super fetchNextBatchOfObjectsWithResponseHandler:
     ^(NSArray *events, NSError *error) {
         if (events) {
             NSNumber *yes = [[NSNumber alloc] initWithBool:YES];
             [events makeObjectsPerformSelector:@selector(setFeatured:)
                                     withObject:yes];
             [yes release], yes = nil;
         }

         handler(events, error);
     }];
}

@end


@implementation LokaliteFeaturedEventStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context
{
    return [self eventStreamWithCategoryName:@"featured" context:context];
}

@end
