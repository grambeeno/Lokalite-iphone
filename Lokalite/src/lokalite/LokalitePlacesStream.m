//
//  LokalitePlacesStream.m
//  Lokalite
//
//  Created by John Debay on 7/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokalitePlacesStream.h"
#import "LokaliteService.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"

@implementation LokalitePlacesStream

#pragma mark - LokaliteStream implementation

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service =
        [[LokaliteService alloc] initWithBaseUrl:[self baseUrl]];
    [service fetchPlacesWithCategory:@""
                     responseHandler:
     ^(NSHTTPURLResponse *response, NSDictionary *jsonObjects, NSError *error) {
         NSArray *parsedObjects = nil;
         if (jsonObjects) {
             NSManagedObjectContext *context = [self context];
             parsedObjects =
                [Business businessObjectsFromJsonObjects:jsonObjects
                                          downloadSource:[self downloadSource]
                                             withContext:context];
         }

         handler(parsedObjects, error);

         [service release];
     }];
}

@end



@implementation LokalitePlacesStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context
{
    NSString *name = @"places";
    return [self streamWithDownloadSourceName:name context:context];
}

@end

