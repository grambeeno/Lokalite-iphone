//
//  TwitterService.m
//  Lokalite
//
//  Created by John Debay on 8/24/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TwitterService.h"

#import "TwitterAccount.h"
#import "TwitterAccount+GeneralHelpers.h"

#import "LokaliteTwitterOAuthSettings.h"

@interface TwitterService ()
@property (nonatomic, retain) YHOAuthTwitterEngine *twitterEngine;
@end


@implementation TwitterService

@synthesize delegate = delegate_;

@synthesize twitterAccount = twitterAccount_;

@synthesize twitterEngine = twitterEngine_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [twitterAccount_ release];
    [twitterEngine_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithTwitterAccount:(TwitterAccount *)account
{
    self = [super init];
    if (self)
        twitterAccount_ = [account retain];

    return self;
}

#pragma mark - Send tweets

- (void)sendTweetWithText:(NSString *)text
{
    [[self twitterEngine] sendUpdate:text];
}

#pragma mark - MGTwitterEngineDelegate implementation

- (void)requestSucceeded:(NSString *)connectionIdentifier
{
}

- (void)requestFailed:(NSString *)identifier withError:(NSError *)error
{
    [[self delegate] twitterService:self didFailToSendTweet:error];
}

- (void)receivedObject:(NSDictionary *)object forRequest:(NSString *)identifier
{
}

- (void)statusesReceived:(NSArray *)statuses forRequest:(NSString *)identifier
{
    [[self delegate] twitterService:self didSendTweet:[statuses lastObject]];
}

- (void)directMessagesReceived:(NSArray *)messages
                    forRequest:(NSString *)identifier
{
}

- (void)userInfoReceived:(NSArray *)userInfo forRequest:(NSString *)identifier
{
}

- (void)miscInfoReceived:(NSArray *)miscInfo forRequest:(NSString *)identifier
{
}

- (void)searchResultsReceived:(NSArray *)searchResults
                   forRequest:(NSString *)identifier
{
}

- (void)imageReceived:(UIImage *)image forRequest:(NSString *)identifier
{
}

- (void)connectionFinished
{
}

#pragma mark - Accessors

- (YHOAuthTwitterEngine *)twitterEngine
{
    if (!twitterEngine_) {
        NSString *key = LokaliteTwitterOAuthConsumerKey;
        NSString *secret = LokaliteTwitterOAuthConsumerSecret;
        twitterEngine_ =
            [[YHOAuthTwitterEngine alloc] initOAuthWithConsumerKey:key
                                                    consumerSecret:secret
                                                          delegate:self];
        OAToken *token = [[self twitterAccount] oauthToken];
        [twitterEngine_ setAccessToken:token];
    }

    return twitterEngine_;
}

@end
