//
//  LokaliteCategoryEventStream.m
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteCategoryEventStream.h"

#import "LokaliteService.h"
#import "LokaliteDownloadSource+GeneralHelpers.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation LokaliteCategoryEventStream

@synthesize categoryName = categoryName_;

#pragma mark - Memory management

- (void)dealloc
{
    [categoryName_ release];
    
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithCategoryName:(NSString *)categoryName
                   baseUrl:(NSURL *)baseUrl
                   context:(NSManagedObjectContext *)context
{
    NSString *sourceName =
        [NSString stringWithFormat:@"events?category=%@", categoryName];
    LokaliteDownloadSource *source =
        [LokaliteDownloadSource downloadSourceWithName:sourceName
                                             inContext:context
                                     createIfNecessary:YES];

    self = [super initWithBaseUrl:baseUrl
                   downloadSource:source
                          context:context];
    if (self)
        categoryName_ = [categoryName copy];

    return self;
}

#pragma mark - LokaliteStream implementation

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service = [self service];
    [service fetchEventsWithCategory:nil
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



#import "UIApplication+GeneralHelpers.h"

@implementation LokaliteCategoryEventStream (InstantiationHelpers)

+ (id)streamWithCategoryName:(NSString *)categoryName
                     context:(NSManagedObjectContext *)context
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    id obj = [[self alloc] initWithCategoryName:categoryName
                                        baseUrl:baseUrl
                                        context:context];

    return [obj autorelease];
}

@end
