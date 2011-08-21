//
//  LokaliteSearchStream.m
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "SearchLokaliteStream.h"

#import "LokaliteService.h"
#import "LokaliteDownloadSource.h"
#import "LokaliteDownloadSource+GeneralHelpers.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"

@implementation SearchLokaliteStream

@synthesize searchType = searchType_;
@synthesize keywords = keywords_;

#pragma mark - Memory management

- (void)dealloc
{
    [keywords_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithSearchStreamType:(LokaliteSearchStreamSearchType)type
                      keywords:(NSString *)keywords
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
        searchType_ = type;
        keywords_ = [keywords copy];
    }

    return self;
}

#pragma mark - LokaliteStream implementation

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    BOOL searchEvents = [self searchType] == LokaliteSearchStreamSearchEvents;
    NSAssert(searchEvents ||
             [self searchType] == LokaliteSearchStreamSearchPlaces,
             @"Invalid search criteria");

    LSResponseHandler responseHandler =
        ^(NSHTTPURLResponse *response, NSDictionary *objects, NSError *error) {
            NSArray *parsedObjects = nil;
            if (objects) {
                NSManagedObjectContext *context = [self context];
                LokaliteDownloadSource *source = [self downloadSource];

                parsedObjects =
                    searchEvents ?
                    [Event eventObjectsFromJsonObjects:objects
                                        downloadSource:source
                                           withContext:context] :
                    [Business businessObjectsFromJsonObjects:objects
                                              downloadSource:source
                                                 withContext:context];
            }

            handler(parsedObjects, error);
        };

    LokaliteService *service =
        [[LokaliteService alloc] initWithBaseUrl:[self baseUrl]];

    if (searchEvents)
        [service searchEventsForKeywords:[self keywords]
                         responseHandler:
         ^(NSHTTPURLResponse *response, NSDictionary *d, NSError *error) {
             responseHandler(response, d, error);
             [service release];
         }];
    else
        [service searchPlacesForKeywords:[self keywords]
                         responseHandler:
         ^(NSHTTPURLResponse *response, NSDictionary *d, NSError *error) {
             responseHandler(response, d, error);
             [service release];
         }];
}

@end


#import "UIApplication+GeneralHelpers.h"

@implementation SearchLokaliteStream (InstantiationHelpers)

+ (id)eventSearchStreamWithKeywords:(NSString *)keywords
                            context:(NSManagedObjectContext *)context
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    LokaliteSearchStreamSearchType type = LokaliteSearchStreamSearchEvents;
    id obj = [[self alloc] initWithSearchStreamType:type
                                           keywords:keywords
                                            baseUrl:baseUrl
                                            context:context];

    return [obj autorelease];
}

+ (id)placesSearchStreamWithKeywords:(NSString *)keywords
                             context:(NSManagedObjectContext *)context
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    LokaliteSearchStreamSearchType type = LokaliteSearchStreamSearchPlaces;
    id obj = [[self alloc] initWithSearchStreamType:type
                                           keywords:keywords
                                            baseUrl:baseUrl
                                            context:context];

    return [obj autorelease];
}

@end
