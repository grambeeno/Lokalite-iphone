//
//  LokaliteCategoryEventStream.m
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "CategoryLokaliteStream.h"

#import "LokaliteService.h"
#import "LokaliteDownloadSource+GeneralHelpers.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation CategoryLokaliteStream

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

- (void)fetchNextBatchOfObjectsFromPage:(NSInteger)page
                        responseHandler:(LKSResponseHandler)handler
{
    void (^responseHandler)(NSHTTPURLResponse *response,
                            NSDictionary *jsonObjects,
                            NSError *error) =
    ^(NSHTTPURLResponse *response, NSDictionary *jsonObjects, NSError *error) {

        NSArray *parsedObjects = nil;

        /* jad: Un-comment out to test error handling */
        /*
        static NSInteger i = 0;
        if (++i % 2 == 0) {
            // jad: forced error handling
            NSDictionary *userInfo =
                [NSDictionary dictionaryWithObject:@"This is not a real error."
                                            forKey:NSLocalizedDescriptionKey];
            error = [NSError errorWithDomain:@"Lokalite"
                                        code:-1
                                    userInfo:userInfo];
        } else
         */

        if (jsonObjects) {
            parsedObjects = [self parseBlock](jsonObjects);

            CLLocationCoordinate2D coord = [self location];
            CLLocation *location = nil;
            if (CLLocationCoordinate2DIsValid(coord))
                location =
                    [[[CLLocation alloc] initWithLatitude:coord.latitude
                                                longitude:coord.longitude]
                     autorelease];

            SEL selector = @selector(updateWithDistanceFromLocation:);
            [parsedObjects makeObjectsPerformSelector:selector
                                           withObject:location];

        }

        handler(parsedObjects, error);
    };

    LokaliteService *service = [self service];
    if ([self streamType] == LokaliteCategoryStreamEvents)
        [service fetchEventsWithCategory:[self categoryName]
                                fromPage:page
                         responseHandler:responseHandler];
    else if ([self streamType] == LokaliteCategoryStreamPlaces)
        [service fetchPlacesWithCategory:[self categoryName]
                                fromPage:page
                         responseHandler:responseHandler];
}

@end



#import "Business.h"
#import "Business+GeneralHelpers.h"

#import "UIApplication+GeneralHelpers.h"

@implementation CategoryLokaliteStream (InstantiationHelpers)

+ (id)eventStreamWithCategoryName:(NSString *)categoryName
                          context:(NSManagedObjectContext *)context
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    CategoryLokaliteStream *stream =
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
    CategoryLokaliteStream *stream =
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
