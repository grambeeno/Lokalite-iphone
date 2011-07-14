//
//  LokaliteStream.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

#import "LokaliteService.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import <CoreData/CoreData.h>

@interface LokaliteStream ()
@end

@implementation LokaliteStream

@synthesize baseUrl = baseUrl_;
@synthesize context = context_;

#pragma mark - Memory management

- (void)dealloc
{
    [baseUrl_ release];
    [context_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url context:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        baseUrl_ = [url copy];
        context_ = [context retain];
    }

    return self;
}

#pragma mark - Walking through the objects

- (void)fetchNextBatchWithResponseHandler:(LKSResponseHandler)handler
{
    [self fetchNextBatchOfObjectsWithResponseHandler:handler];
}

#pragma mark - Protected interface

- (void)fetchNextBatchOfObjectsWithResponseHandler:(LKSResponseHandler)handler
{
    NSAssert1(NO, @"Must be implemented by subclasses.",
              NSStringFromSelector(_cmd));
}

@end
