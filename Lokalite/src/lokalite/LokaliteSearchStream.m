//
//  LokaliteSearchStream.m
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteSearchStream.h"

#import "LokaliteService.h"
#import "LokaliteDownloadSource.h"
#import "LokaliteDownloadSource+GeneralHelpers.h"

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

- (id)initWithKeywords:(NSString *)keywords
               baseUrl:(NSURL *)baseUrl
               context:(NSManagedObjectContext *)context
{
    NSString *sourceName =
        [NSString stringWithFormat:@"search/events?keywords=%@", keywords];
    LokaliteDownloadSource *source =
        [LokaliteDownloadSource downloadSourceWithName:sourceName
                                             inContext:context
                                     createIfNecessary:YES];

    self = [super initWithBaseUrl:baseUrl
                   downloadSource:source
                          context:context];
    if (self) {
        keywords_ = [keywords copy];
        includeEvents_ = YES;
        includeBusinesses_ = NO;
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


#import "UIApplication+GeneralHelpers.h"

@implementation LokaliteSearchStream (InstantiationHelpers)

+ (id)streamWithKeywords:(NSString *)keywords
                 context:(NSManagedObjectContext *)context
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    id obj = [[self alloc] initWithKeywords:keywords
                                    baseUrl:baseUrl
                                    context:context];

    return [obj autorelease];
}

@end
