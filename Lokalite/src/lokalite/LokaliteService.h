//
//  LokaliteService.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^LSResponseHandler)(NSDictionary *, NSError *);

@interface LokaliteService : NSObject

@property (nonatomic, copy, readonly) NSURL *baseUrl;

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url;

#pragma mark - Events

- (void)fetchFeaturedEventsWithResponseHandler:(LSResponseHandler)handler;

@end
