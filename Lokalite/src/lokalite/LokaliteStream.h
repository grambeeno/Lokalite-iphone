//
//  LokaliteStream.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

typedef void(^LKSResponseHandler)(NSArray *, NSError *);

@interface LokaliteStream : NSObject

@property (nonatomic, copy, readonly) NSURL *baseUrl;
@property (nonatomic, retain, readonly) NSManagedObjectContext *context;

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url context:(NSManagedObjectContext *)context;

#pragma mark - Walking through the objects

- (void)fetchNextBatchWithResponseHandler:(LKSResponseHandler)handler;

#pragma mark - Protected interface; do not call

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler;

@end
