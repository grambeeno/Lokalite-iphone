//
//  TwitterOAuthWebViewDelegate.h
//  Lokalite
//
//  Created by John Debay on 8/23/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol TwitterOAuthWebViewDelegate;

@interface TwitterOAuthWebView : UIViewController <UIWebViewDelegate>
{
}

@property (nonatomic, assign) id<TwitterOAuthWebViewDelegate> delegate;

@property (nonatomic, copy, readonly) NSURL *url;
@property (nonatomic, copy, readonly) NSURL *callbackUrl;

#pragma mark - Initialization

- (id)initWithUrl:(NSURL *)url callbackUrl:(NSURL *)callbackUrl;

@end


@protocol TwitterOAuthWebViewDelegate <NSObject>

- (void)oauthWebView:(TwitterOAuthWebView *)webView
     didReceiveToken:(NSString *)token
         andVerifier:(NSString *)verifier;
- (void)oauthWebView:(TwitterOAuthWebView *)webView
    didFailWithError:(NSError *)error;

@end
