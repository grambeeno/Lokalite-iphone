//
//  LokaliteStream.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;
@class LokaliteService;

typedef void(^LKSResponseHandler)(NSArray *, NSError *);

@interface LokaliteStream : NSObject

@property (nonatomic, copy, readonly) NSURL *baseUrl;
@property (nonatomic, retain, readonly) NSManagedObjectContext *context;

@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *password;

@property (nonatomic, retain, readonly) LokaliteService *service;

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url context:(NSManagedObjectContext *)context;

#pragma mark - Making authenticated requests

- (void)setEmail:(NSString *)email password:(NSString *)password;
- (void)removeEmailAndPassword;

#pragma mark - Walking through the objects

- (void)fetchNextBatchWithResponseHandler:(LKSResponseHandler)handler;

#pragma mark - Protected interface; do not call

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler;

@end



@class NSManagedObjectContext;

@interface LokaliteStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context;

@end
