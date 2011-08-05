//
//  LokaliteStream.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

#import "LokaliteObject+GeneralHelpers.h"
#import "LokaliteDownloadSource.h"

#import "LokaliteService.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import <CoreData/CoreData.h>

@interface LokaliteStream ()

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

@end

@implementation LokaliteStream

@synthesize baseUrl = baseUrl_;
@synthesize downloadSource = downloadSource_;
@synthesize context = context_;

@synthesize objectsPerPage = objectsPerPage_;
@synthesize pagesFetched = pagesFetched_;
@synthesize hasMorePages = hasMorePages_;

@synthesize email = email_;
@synthesize password = password_;

@synthesize service = service_;

#pragma mark - Memory management

- (void)dealloc
{
    [baseUrl_ release];
    [downloadSource_ release];
    [context_ release];

    [email_ release];
    [password_ release];

    [service_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url
       downloadSource:(LokaliteDownloadSource *)source
              context:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        baseUrl_ = [url copy];
        downloadSource_ = [source retain];
        context_ = [context retain];

        objectsPerPage_ = [[self class] defaultObjectsPerPage];
        pagesFetched_ = 0;
        hasMorePages_ = YES;
    }

    return self;
}

#pragma mark - Making authenticated requests

- (void)setEmail:(NSString *)email password:(NSString *)password
{
    [self setEmail:email];
    [self setPassword:password];
    [[self service] setEmail:email password:password];
}

- (void)removeEmailAndPassword
{
    [self setEmail:nil password:nil];
    [[self service] removeEmailAndPassword];
}

#pragma mark - Walking through the objects

- (void)fetchNextBatchWithResponseHandler:(LKSResponseHandler)handler
{
    [self fetchNextBatchOfObjectsWithResponseHandler:
     ^(NSArray *objects, NSError *error) {
         ++pagesFetched_;
         hasMorePages_ = [objects count] == [self objectsPerPage];

         LokaliteDownloadSource *source = [self downloadSource];
         [source setLastUpdated:[NSDate date]];

         handler(objects, error);
     }];
}

- (void)resetStream
{
    pagesFetched_ = 0;
    hasMorePages_ = YES;
}

#pragma mark - Protected interface

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    NSAssert1(NO, @"Must be implemented by subclasses.",
              NSStringFromSelector(_cmd));
}

#pragma mark - Accessors

- (LokaliteService *)service
{
    if (!service_)
        service_ = [[LokaliteService alloc] initWithBaseUrl:[self baseUrl]];

    return service_;
}

#pragma mark - Default configuration

+ (NSUInteger)defaultObjectsPerPage
{
    NSBundle *bundle = [NSBundle mainBundle];
    NSNumber *n =
        [bundle objectForInfoDictionaryKey:@"LokaliteDefaultObjectsPerFetch"];

    return [n integerValue];
}

@end


#import "LokaliteDownloadSource+GeneralHelpers.h"
#import "UIApplication+GeneralHelpers.h"
#import <CoreData/CoreData.h>

@implementation LokaliteStream (InstantiationHelpers)

+ (id)streamWithDownloadSourceName:(NSString *)sourceName
                           context:(NSManagedObjectContext *)context
{
    LokaliteDownloadSource *source =
        [LokaliteDownloadSource downloadSourceWithName:sourceName
                                             inContext:context
                                     createIfNecessary:YES];

    return [self streamWithDownloadSource:source context:context];
}

//+ (id)streamWithDownloadSourceName:(NSString *)downloadSourceName
+ (id)streamWithDownloadSource:(LokaliteDownloadSource *)source
                       context:(NSManagedObjectContext *)context
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    id obj = [[self alloc] initWithBaseUrl:baseUrl
                            downloadSource:source
//                        downloadSourceName:downloadSourceName
                                   context:context];

    return [obj autorelease];
}

@end
