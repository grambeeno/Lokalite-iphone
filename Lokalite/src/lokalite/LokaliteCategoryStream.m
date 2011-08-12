//
//  LokaliteCategoryEventStream.m
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteCategoryStream.h"

#import "LokaliteService.h"
#import "LokaliteDownloadSource+GeneralHelpers.h"


@implementation LokaliteCategoryStream

@synthesize categoryName = categoryName_;
@synthesize streamType = streamType_;
@synthesize parseBlock = parseBlock_;

#pragma mark - Memory management

- (void)dealloc
{
    [categoryName_ release];
    [parseBlock_ release];
    
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithCategoryName:(NSString *)categoryName
                streamType:(LokaliteCategoryStreamType)streamType
                   baseUrl:(NSURL *)baseUrl
                   context:(NSManagedObjectContext *)context
{
    NSString *rootName =
        streamType == LokaliteCategoryStreamEvents ? @"events" : @"places";

    NSString *sourceName =
        [NSString stringWithFormat:@"%@?category=%@", rootName, categoryName];
    LokaliteDownloadSource *source =
        [LokaliteDownloadSource downloadSourceWithName:sourceName
                                             inContext:context
                                     createIfNecessary:YES];

    self = [super initWithBaseUrl:baseUrl
                   downloadSource:source
                          context:context];
    if (self) {
        categoryName_ = [categoryName copy];
        streamType_ = streamType;
    }

    return self;
}

#pragma mark - LokaliteStream implementation

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service = [self service];
    [service fetchEventsWithCategory:nil
                            fromPage:[self pagesFetched] + 1
                     responseHandler:
     ^(NSHTTPURLResponse *response, NSDictionary *jsonObjects, NSError *error) {
         NSArray *parsedObjects = nil;
         if (jsonObjects)
             parsedObjects = [self parseBlock](jsonObjects);

         handler(parsedObjects, error);
     }];
}

@end



#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"

#import "UIApplication+GeneralHelpers.h"

@implementation LokaliteCategoryStream (InstantiationHelpers)

+ (id)eventStreamWithCategoryName:(NSString *)categoryName
                          context:(NSManagedObjectContext *)context
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    LokaliteCategoryStream *stream =
        [[self alloc] initWithCategoryName:categoryName
                                streamType:LokaliteCategoryStreamEvents
                                   baseUrl:baseUrl
                                   context:context];
    [stream setParseBlock:^(NSDictionary *jsonObjects) {
        return [Event eventObjectsFromJsonObjects:jsonObjects
                                   downloadSource:[stream downloadSource]
                                      withContext:context];
    }];

    return [stream autorelease];
}

+ (id)placeStreamWithCategoryName:(NSString *)categoryName
                          context:(NSManagedObjectContext *)context
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    LokaliteCategoryStream *stream =
        [[self alloc] initWithCategoryName:categoryName
                                streamType:LokaliteCategoryStreamPlaces
                                   baseUrl:baseUrl
                                   context:context];
    [stream setParseBlock:^(NSDictionary *jsonObjects) {
        return [Business businessObjectsFromJsonObjects:jsonObjects
                                         downloadSource:[stream downloadSource]
                                            withContext:context];
    }];

    return [stream autorelease];
}

@end
