//
//  PlaceEventLokaliteStream.m
//  Lokalite
//
//  Created by John Debay on 8/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlaceEventLokaliteStream.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"

#import "LokaliteService.h"

@implementation PlaceEventLokaliteStream

@synthesize place = place_;

#pragma mark - Memory management

- (void)dealloc
{
    [place_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithPlace:(Business *)place
     downloadSource:(LokaliteDownloadSource *)downloadSource
            baseUrl:(NSURL *)baseUrl
            context:(NSManagedObjectContext *)context
{
    self = [super initWithBaseUrl:baseUrl
                   downloadSource:downloadSource
                          context:context];
    if (self)
        place_ = [place retain];

    return self;
}

#pragma mark - LokaliteStream implementation

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service = [self service];
    [service fetchEventsForPlaceId:[[self place] identifier]
                          fromPage:[self pagesFetched] + 1
                   responseHandler:
     ^(NSHTTPURLResponse *response, NSDictionary *jsonObjects, NSError *error) {
         NSArray *parsedObjects = nil;
         if (jsonObjects)
             parsedObjects =
                [Business businessObjectsFromJsonObjects:jsonObjects
                                          downloadSource:[self downloadSource]
                                             withContext:[self context]];

         handler(parsedObjects, error);
     }];
}

@end


#import "UIApplication+GeneralHelpers.h"
#import "LokaliteDownloadSource.h"
#import "LokaliteDownloadSource+GeneralHelpers.h"

@implementation PlaceEventLokaliteStream (InstantiationHelpers)

+ (id)streamWithPlace:(Business *)place context:(NSManagedObjectContext *)moc
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    NSString *sourceName =
        [NSString stringWithFormat:@"events?organization_id=%@", [place name]];
    LokaliteDownloadSource *source =
        [LokaliteDownloadSource downloadSourceWithName:sourceName
                                             inContext:moc
                                     createIfNecessary:YES];

    return [[[self alloc] initWithPlace:place
                         downloadSource:source
                                baseUrl:baseUrl
                                context:moc] autorelease];
}

@end
