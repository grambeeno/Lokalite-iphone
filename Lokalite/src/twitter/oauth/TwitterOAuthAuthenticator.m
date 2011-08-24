//
//  TwitterOAuthAuthenticator.m
//  Lokalite
//
//  Created by John Debay on 8/23/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TwitterOauthAuthenticator.h"
#import "OAuth.h"

@interface TwitterOAuthAuthenticator ()
@property (nonatomic, retain) OAuth *oauth;
+ (dispatch_queue_t)dispatchQueue;
@end


@implementation TwitterOAuthAuthenticator

@synthesize delegate = delegate_;
@synthesize consumerKey = consumerKey_, consumerSecret = consumerSecret_;
@synthesize oauth = oauth_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;
    [oauth_ release];
    [consumerKey_ release];
    [consumerSecret_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithConsumerKey:(NSString *)key consumerSecret:(NSString *)secret
{
    self = [super init];
    if (self) {
        consumerKey_ = [key copy];
        consumerSecret_ = [secret copy];
    }

    return self;
}

#pragma mark - Authorization

- (void)requestTokenWithCallbackUrl:(NSString *)callbackUrl
{
    OAuth *oauth = [self oauth];
    dispatch_async([[self class] dispatchQueue], ^{
        [oauth synchronousRequestTwitterTokenWithCallbackUrl:callbackUrl];
    });
}

- (void)authorizeTokenWithVerifier:(NSString *)verifier
{
    OAuth *oauth = [self oauth];
    dispatch_async([[self class] dispatchQueue], ^{
        [oauth synchronousAuthorizeTwitterTokenWithVerifier:verifier];
    });
}

#pragma mark - OAuthTwitterCallbacks implementation

//
// Note that these methods are called on asynchronous threads.
//

- (void)requestTwitterTokenDidSucceed:(OAuth *)oAuth
{
    NSString *token = [oAuth oauth_token];

    // Add the force_login parameter per recommendation by Twitter here:
    //
    //  http://dev.twitter.com/pages/application-permission-model-faq
    //
    // As of 5/21/11, they say it's not supported, but will be in the future.
    NSString *urlString =
        [NSString stringWithFormat:
         @"https://api.twitter.com/oauth/authorize?"
          "oauth_token=%@&force_login=true", token];
    NSURL *url = [NSURL URLWithString:urlString];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[self delegate] oauthAuthenticator:self didObtainAuthUrl:url];
    });
}

- (void)requestTwitterTokenDidFail:(OAuth *)oAuth error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self delegate] oauthAuthenticator:self didFailToObtainAuthUrl:error];
    });
}

- (void)authorizeTwitterTokenDidSucceed:(OAuth *)oAuth
{
    NSString *userId = [oAuth user_id], *username = [oAuth screen_name];
    NSString *token = [oAuth oauth_token], *secret = [oAuth oauth_token_secret];

    dispatch_async(dispatch_get_main_queue(), ^{
        [[self delegate] oauthAuthenticator:self
                            didObtainUserId:userId
                                andUsername:username
                                 oauthToken:token
                                oauthSecret:secret];
    });
}

- (void)authorizeTwitterTokenDidFail:(OAuth *)oAuth error:(NSError *)error
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self delegate] oauthAuthenticator:self didFailToAuthorizeToken:error];
    });
}

#pragma mark - Accessors

- (OAuth *)oauth
{
    if (!oauth_) {
        oauth_ = [[OAuth alloc] initWithConsumerKey:[self consumerKey]
                                  andConsumerSecret:[self consumerSecret]];
        [oauth_ setDelegate:self];
    }

    return oauth_;
}

+ (dispatch_queue_t)dispatchQueue
{
    return dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
}

@end

