//
//  LokaliteFeaturedEventStream.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "FeaturedEventLokaliteStream.h"

#import "LokaliteService.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation FeaturedEventLokaliteStream

- (void)fetchNextBatchOfObjectsFromPage:(NSInteger)page
                        responseHandler:(LKSResponseHandler)handler
{
    [super fetchNextBatchOfObjectsFromPage:page responseHandler:
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


@implementation FeaturedEventLokaliteStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context
{
    return [self eventStreamWithCategoryName:@"featured" context:context];
}

@end
