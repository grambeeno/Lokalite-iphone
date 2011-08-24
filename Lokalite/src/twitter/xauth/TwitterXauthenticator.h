//
//  Copyright High Order Bit, Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>

@class XAuthTwitterEngine;
//@class MGTwitterEngine;
@protocol TwitterXauthenticatorDelegate;

@interface TwitterXauthenticator : NSObject
{
    id<TwitterXauthenticatorDelegate> delegate;

    NSString * consumerKey, * consumerSecret;
    NSString * username, * password;

    XAuthTwitterEngine * twitter;
    //MGTwitterEngine * twitter;
}

@property (nonatomic, assign) id<TwitterXauthenticatorDelegate> delegate;
@property (nonatomic, copy, readonly) NSString * username;
@property (nonatomic, copy, readonly) NSString * password;

- (id)initWithConsumerKey:(NSString *)consumerKey
           consumerSecret:(NSString *)consumerSecret;

- (void)authWithUsername:(NSString *)username password:(NSString *)password;

@end

@protocol TwitterXauthenticatorDelegate

/*
- (void)xauthenticator:(TwitterXauthenticator *)xauthenticator
       didReceiveToken:(NSString *)key
                secret:(NSString *)secret
                userId:(NSNumber *)userId
           forUsername:(NSString *)username
           andPassword:(NSString *)password;
 */

- (void)xauthenticator:(TwitterXauthenticator *)xauthenticator
       didReceiveToken:(NSString *)key
                secret:(NSString *)secret
              username:(NSString *)username
                userId:(NSString *)userId;

- (void)xauthenticator:(TwitterXauthenticator *)xauthenticator
  failedToAuthUsername:(NSString *)username
           andPassword:(NSString *)password
                 error:(NSError *)error;


@end

