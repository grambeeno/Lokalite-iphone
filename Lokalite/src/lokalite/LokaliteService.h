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
- (void)fetchEventsWithCategory:(NSString *)category
                responseHandler:(LSResponseHandler)handler;

#pragma mark - Search

- (void)searchForKeywords:(NSArray *)keywords
            includeEvents:(BOOL)includeEvents
        includeBusinesses:(BOOL)includeBusinesses
          responseHandler:(LSResponseHandler)handler;

#pragma mark - URLs

- (NSURL *)featuredEventUrl;

@end
