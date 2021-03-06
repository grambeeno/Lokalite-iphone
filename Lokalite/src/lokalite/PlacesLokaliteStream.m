//
//  LokalitePlacesStream.m
//  Lokalite
//
//  Created by John Debay on 7/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlacesLokaliteStream.h"
#import "LokaliteService.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"

@implementation PlacesLokaliteStream

#pragma mark - LokaliteStream implementation

- (void)fetchNextBatchOfObjectsFromPage:(NSInteger)page
                        responseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service =
        [[LokaliteService alloc] initWithBaseUrl:[self baseUrl]];
    [service fetchPlacesWithCategory:nil
                            fromPage:page
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



@implementation PlacesLokaliteStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context
{
    NSString *name = @"places";
    return [self streamWithDownloadSourceName:name context:context];
}

@end

