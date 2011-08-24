//
//  TwitterOAuthWebView.m
//  Lokalite
//
//  Created by John Debay on 8/23/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TwitterOAuthWebView.h"

#import "UIApplication+GeneralHelpers.h"

@interface TwitterOAuthWebView ()
- (UIWebView *)webView;
@end


@implementation TwitterOAuthWebView

@synthesize delegate = delegate_;
@synthesize url = url_;
@synthesize callbackUrl = callbackUrl_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [url_ release];
    [callbackUrl_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithUrl:(NSURL *)url callbackUrl:(NSURL *)callbackUrl
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        url_ = [url copy];
        callbackUrl_ = [callbackUrl copy];
    }

    return self;
}

#pragma mark - UIViewController implementation

- (void)loadView
{
    [super loadView];

    UIWebView *webView = [[UIWebView alloc] initWithFrame:CGRectZero];
    [webView setDelegate:self];
    [self setView:webView];
    [webView release], webView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self webView] loadRequest:[NSURLRequest requestWithURL:[self url]]];
}

#pragma mark - UIWebViewDelegate implementation

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] networkActivityIsStarting];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [[UIApplication sharedApplication] networkActivityDidFinish];
}

- (BOOL)webView:(UIWebView *)webView
    shouldStartLoadWithRequest:(NSURLRequest *)request
                navigationType:(UIWebViewNavigationType)navigationType
{
    NSURL *url = [request URL];
    NSString *urlString = [url absoluteString];
    NSString *callbackUrl = [[self callbackUrl] absoluteString];
    NSRange where = [urlString rangeOfString:callbackUrl];

    if (where.location == 0 && where.length == [callbackUrl length]) {
        NSRange questionMarkRange = [urlString rangeOfString:@"?"];
        NSRange paramRange =
            NSMakeRange(questionMarkRange.location + questionMarkRange.length,
                        [urlString length] - questionMarkRange.location -
                        questionMarkRange.length);
        NSString *paramString = [urlString substringWithRange:paramRange];
        NSArray *components = [paramString componentsSeparatedByString:@"&"];
        NSMutableDictionary *params =
            [NSMutableDictionary dictionaryWithCapacity:[components count]];
        [components enumerateObjectsUsingBlock:
         ^(NSString *component, NSUInteger idx, BOOL *stop) {
             NSArray *a = [component componentsSeparatedByString:@"="];
             if ([a count] == 2)
                 [params setObject:[a objectAtIndex:1]
                            forKey:[a objectAtIndex:0]];
         }];

        NSString *token = [params objectForKey:@"oauth_token"];
        NSString *verifier = [params objectForKey:@"oauth_verifier"];

        if ([token length] && [verifier length])
            [[self delegate] oauthWebView:self
                          didReceiveToken:token
                              andVerifier:verifier];

        return NO;
    }

    return YES;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [[self delegate] oauthWebView:self didFailWithError:error];
}

#pragma mark - Accessors

- (UIWebView *)webView
{
    return (UIWebView *) [self view];
}

@end
