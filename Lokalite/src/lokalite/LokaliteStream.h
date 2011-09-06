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

@property (nonatomic, assign, readonly) NSUInteger pagesFetched;
@property (nonatomic, assign, readonly) NSUInteger hasMorePages;

@property (nonatomic, copy) NSString *orderBy;

@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *password;

@property (nonatomic, retain, readonly) LokaliteService *service;

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url
       downloadSource:(LokaliteDownloadSource *)source
              context:(NSManagedObjectContext *)context;

#pragma mark - Pagination

- (void)setObjectsPerPage:(NSInteger)objectsPerPage;
- (NSInteger)objectsPerPage;

#pragma mark - Location

- (void)setLocation:(CLLocationCoordinate2D)location;
- (CLLocationCoordinate2D)location;
- (void)clearLocation;

#pragma mark - Making authenticated requests

- (void)setEmail:(NSString *)email password:(NSString *)password;
- (void)removeEmailAndPassword;

#pragma mark - Walking through the objects

- (void)fetchMostRecentBatchWithResponseHandler:(LKSResponseHandler)handler;
- (void)fetchNextBatchWithResponseHandler:(LKSResponseHandler)handler;
- (void)resetStream;


#pragma mark - Protected interface; do not call

- (void)fetchNextBatchOfObjectsFromPage:(NSInteger)page
                        responseHandler:(LKSResponseHandler)handler;

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
