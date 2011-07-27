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

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

@end

@implementation LokaliteStream

@synthesize baseUrl = baseUrl_;
@synthesize context = context_;

@synthesize email = email_;
@synthesize password = password_;

@synthesize service = service_;

#pragma mark - Memory management

- (void)dealloc
{
    [baseUrl_ release];
    [context_ release];

    [email_ release];
    [password_ release];

    [service_ release];

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
    [self fetchNextBatchOfObjectsWithResponseHandler:handler];
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

@end


#import "UIApplication+GeneralHelpers.h"
#import <CoreData/CoreData.h>

@implementation LokaliteStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    id obj = [[self alloc] initWithBaseUrl:baseUrl context:context];

    return [obj autorelease];
}

@end
