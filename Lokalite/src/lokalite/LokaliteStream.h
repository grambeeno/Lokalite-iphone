//
//  LokaliteStream.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@class NSManagedObjectContext;
@class LokaliteService, LokaliteDownloadSource;

typedef void(^LKSResponseHandler)(NSArray *, NSError *);

@interface LokaliteStream : NSObject

@property (nonatomic, copy, readonly) NSURL *baseUrl;
@property (nonatomic, retain, readonly) LokaliteDownloadSource *downloadSource;
@property (nonatomic, retain, readonly) NSManagedObjectContext *context;

@property (nonatomic, assign) NSUInteger objectsPerPage;
@property (nonatomic, assign, readonly) NSUInteger pagesFetched;
@property (nonatomic, assign, readonly) NSUInteger hasMorePages;

@property (nonatomic, assign) CLLocationCoordinate2D location;

@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *password;

@property (nonatomic, retain, readonly) LokaliteService *service;

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url
       downloadSource:(LokaliteDownloadSource *)source
              context:(NSManagedObjectContext *)context;

#pragma mark - Making authenticated requests

- (void)setEmail:(NSString *)email password:(NSString *)password;
- (void)removeEmailAndPassword;

#pragma mark - Walking through the objects

- (void)fetchNextBatchWithResponseHandler:(LKSResponseHandler)handler;
- (void)resetStream;

#pragma mark - Protected interface; do not call

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler;

#pragma mark - Default configuration

+ (NSUInteger)defaultObjectsPerPage;

@end



@class NSManagedObjectContext;

@interface LokaliteStream (InstantiationHelpers)

+ (id)streamWithDownloadSourceName:(NSString *)sourceName
                           context:(NSManagedObjectContext *)context;

+ (id)streamWithDownloadSource:(LokaliteDownloadSource *)downloadSource
                       context:(NSManagedObjectContext *)context;

@end
