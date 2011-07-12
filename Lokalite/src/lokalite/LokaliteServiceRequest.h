//
//  LokaliteServiceRequest.h
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    LKRequestMethodGET,
    LKRequestMethodPOST
} LKRequestMethod;

typedef void(^LKRequestHandler)(NSData *, NSHTTPURLResponse *, NSError *);

@interface LokaliteServiceRequest : NSObject

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSDictionary *parameters;
@property (nonatomic, assign, readonly) LKRequestMethod requestMethod;

#pragma mark - Initialization

- (id)initWithUrl:(NSURL *)url
       parameters:(NSDictionary *)params
    requestMethod:(LKRequestMethod)requestMethod;

#pragma mark - Performing the request

- (void)performRequestWithHandler:(LKRequestHandler)handler;

@end
