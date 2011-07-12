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

#pragma mark - Events

- (void)fetchFeaturedEventsWithResponseHandler:(LSResponseHandler)handler;

@end
