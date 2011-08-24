//
//  TwitterOAuthAuthenticator.h
//  Lokalite
//
//  Created by John Debay on 8/23/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OAuthTwitterCallbacks.h"

@protocol TwitterOAuthAuthenticatorDelegate;

@interface TwitterOAuthAuthenticator : NSObject <OAuthTwitterCallbacks>
{
}

@property (nonatomic, assign) id<TwitterOAuthAuthenticatorDelegate> delegate;

@property (nonatomic, copy, readonly ) NSString *consumerKey;
@property (nonatomic, copy, readonly ) NSString *consumerSecret;

#pragma mark - Initialization

- (id)initWithConsumerKey:(NSString *)key consumerSecret:(NSString *)secret;

#pragma mark - Authorization

- (void)requestTokenWithCallbackUrl:(NSString *)callbackUrl;
- (void)authorizeTokenWithVerifier:(NSString *)verifier;

@end


@protocol TwitterOAuthAuthenticatorDelegate <NSObject>

- (void)oauthAuthenticator:(TwitterOAuthAuthenticator *)authenticator
          didObtainAuthUrl:(NSURL *)tokenUrl;
- (void)oauthAuthenticator:(TwitterOAuthAuthenticator *)authenticator
    didFailToObtainAuthUrl:(NSError *)error;

- (void)oauthAuthenticator:(TwitterOAuthAuthenticator *)authenticator
           didObtainUserId:(NSString *)userId
               andUsername:(NSString *)username
                oauthToken:(NSString *)key
               oauthSecret:(NSString *)secret;

- (void)oauthAuthenticator:(TwitterOAuthAuthenticator *)authenticator
   didFailToAuthorizeToken:(NSError *)error;

@end
