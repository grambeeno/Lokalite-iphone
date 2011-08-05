//
//  LokaliteSearchStream.m
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteSearchStream.h"
#import "LokaliteService.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation LokaliteSearchStream

@synthesize keywords = keywords_;

@synthesize includeEvents = includeEvents_;
@synthesize includeBusinesses = includeBusinesses_;

#pragma mark - Memory management

- (void)dealloc
{
    [keywords_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url
       downloadSource:(LokaliteDownloadSource *)downloadSource
              context:(NSManagedObjectContext *)context
{
    self = [super initWithBaseUrl:url
                   downloadSource:downloadSource
                          context:context];
    if (self) {
        includeEvents_ = YES;
        includeBusinesses_ = YES;
    }

    return self;
}

#pragma mark - LokaliteStream implementation

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service =
        [[LokaliteService alloc] initWithBaseUrl:[self baseUrl]];
    [service searchForKeywords:[self keywords]
                 includeEvents:[self includeEvents]
             includeBusinesses:[self includeBusinesses]
               responseHandler:
     ^(NSHTTPURLResponse *response, NSDictionary *jsonObjects, NSError *error) {
         NSArray *parsedObjects = nil;
         if (jsonObjects)
             parsedObjects =
                [Event eventObjectsFromJsonObjects:jsonObjects
                                    downloadSource:[self downloadSource]
                                       withContext:[self context]];

         handler(parsedObjects, error);

         [service release];
     }];
}

@end
