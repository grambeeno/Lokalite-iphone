//
//  TwitterService.h
//  Lokalite
//
//  Created by John Debay on 8/24/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "YHOAuthTwitterEngine.h"

@class TwitterAccount;
@protocol TwitterServiceDelegate;

@interface TwitterService : NSObject <MGTwitterEngineDelegate>

@property (nonatomic, retain) id<TwitterServiceDelegate> delegate;

@property (nonatomic, retain, readonly) TwitterAccount *twitterAccount;

#pragma mark - Initialization

- (id)initWithTwitterAccount:(TwitterAccount *)account;

#pragma mark - Send tweets

- (void)sendTweetWithText:(NSString *)text;

@end


@protocol TwitterServiceDelegate <NSObject>

- (void)twitterService:(TwitterService *)service
          didSendTweet:(NSDictionary *)tweetData;
- (void)twitterService:(TwitterService *)service
    didFailToSendTweet:(NSString *)tweetText
                 error:(NSError *)error;

@end
