//
//  TwitterOAuthLogInViewController.m
//  Lokalite
//
//  Created by John Debay on 8/23/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TwitterOAuthLogInViewController.h"

#import "LokaliteTwitterOAuthSettings.h"

#import "LokaliteAppDelegate.h"

#import "UIApplication+GeneralHelpers.h"
#import "NSError+GeneralHelpers.h"
#import "UIColor+GeneralHelpers.h"

@interface TwitterOAuthLogInViewController ()
@property (nonatomic, retain) UITableViewCell *activeCell;
@property (nonatomic, retain) TwitterOAuthAuthenticator *authenticator;

- (void)cancelModalWebViewAnimated:(BOOL)animated
                        completion:(void (^)(void))completion;

- (void)presentError:(NSError *)error;

- (void)displayActivityAnimated:(BOOL)animated
                     completion:(void(^)(void))completion;
- (void)hideActivityAnimated:(BOOL)animated
                  completion:(void(^)(void))completion;

- (UIViewController *)modalWebViewControllerForUrl:(NSURL *)url;
@end


@implementation TwitterOAuthLogInViewController

@synthesize canCancel = canCancel_;

@synthesize logInDidStartHandler = logInDidStartHandler_;
@synthesize logInDidSucceedHandler = logInDidSucceedHandler_;
@synthesize logInDidFailHandler = logInDidFailHandler_;

@synthesize activeCell = activeCell_;
@synthesize authenticator = authenticator_;

@synthesize authorizeCell = authorizeCell_;
@synthesize contactingTwitterCell = contactingTwitterCell_;

#pragma mark - Memory management

- (void)dealloc
{
    [logInDidStartHandler_ release];
    [logInDidSucceedHandler_ release];
    [logInDidFailHandler_ release];

    [activeCell_ release];
    [authenticator_ release];

    [authorizeCell_ release];
    [contactingTwitterCell_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)init
{
    self = [super initWithNibName:@"TwitterOAuthLogInView" bundle:nil];
    if (self) {
        canCancel_ = YES;
        [self setTitle:NSLocalizedString(@"twitter.log-in.title", nil)];
    }

    return self;
}

#pragma mark - UI events

- (void)cancel:(id)sender
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)cancelModalWebView:(id)sender
{
    [self cancelModalWebViewAnimated:YES completion:nil];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[[self navigationController] navigationBar]
     setTintColor:[UIColor navigationBarTintColor]];

    if ([self canCancel]) {
        UIBarButtonItem *cancelButton =
            [[UIBarButtonItem alloc]
             initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
             target:self action:@selector(cancel:)];
        [[self navigationItem] setLeftBarButtonItem:cancelButton];
        [cancelButton release], cancelButton = nil;
    }

    CGFloat pointSize = [[[[self authorizeCell] textLabel] font] pointSize];
    [[[self authorizeCell] textLabel]
     setText:NSLocalizedString(@"twitter.oauth.authorize.button.title", nil)];
    [[[self authorizeCell] textLabel] setTextAlignment:UITextAlignmentCenter];
    [[[self authorizeCell] textLabel] setFont:
     [UIFont boldSystemFontOfSize:pointSize]];

    [self setActiveCell:[self authorizeCell]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    return io != UIInterfaceOrientationPortraitUpsideDown;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView
titleForFooterInSection:(NSInteger)section
{
    return NSLocalizedString(@"twitter.oauth.authorize.explanation", nil);
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [self activeCell];
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self activeCell] == [self authorizeCell]) {
        [self displayActivityAnimated:YES completion:^{
            NSString *url = LokaliteTwitterOAuthTokenCallbackUrl;
            [[self authenticator] requestTokenWithCallbackUrl:url];
        }];

        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
}

#pragma mark - TwitterOauthAuthenticator implementation

- (void)oauthAuthenticator:(TwitterOAuthAuthenticator *)authenticator
          didObtainAuthUrl:(NSURL *)tokenUrl
{
    UIViewController *webView = [self modalWebViewControllerForUrl:tokenUrl];
    [self presentModalViewController:webView animated:YES];
    [self hideActivityAnimated:YES completion:nil];
}

- (void)oauthAuthenticator:(TwitterOAuthAuthenticator *)authenticator
   didFailToAuthorizeToken:(NSError *)error
{
    [self presentError:error];
    if ([self logInDidFailHandler])
        [self logInDidFailHandler](error);
}

- (void)oauthAuthenticator:(TwitterOAuthAuthenticator *)authenticator
    didFailToObtainAuthUrl:(NSError *)error
{

    [self presentError:error];
    [self hideActivityAnimated:YES completion:nil];
}

- (void)oauthAuthenticator:(TwitterOAuthAuthenticator *)authenticator
           didObtainUserId:(NSString *)userIdString
               andUsername:(NSString *)username
                oauthToken:(NSString *)token
               oauthSecret:(NSString *)secret
{
    NSNumber *userId =
        [NSNumber numberWithLongLong:[userIdString longLongValue]];

    if ([self logInDidSucceedHandler])
        [self logInDidSucceedHandler](userId, username, token, secret);

    NSLog(@"Created an account with user ID: %@, username: %@", userId, username);
}

#pragma mark - OAuthWebViewDelegate implementation

- (void)oauthWebView:(TwitterOAuthWebView *)webView
     didReceiveToken:(NSString *)token
         andVerifier:(NSString *)verifier
{
    [self cancelModalWebViewAnimated:YES
                          completion:
     ^{
         [[self authenticator] authorizeTokenWithVerifier:verifier];

         if ([self logInDidStartHandler])
             [self logInDidStartHandler]();
     }];
}

- (void)oauthWebView:(TwitterOAuthWebView *)webView
    didFailWithError:(NSError *)error
{
    [self presentError:error];
    [self cancelModalWebView:self];
}

#pragma mark - UI helpers

- (void)displayActivityAnimated:(BOOL)animated
                     completion:(void (^)(void))completion
{
    UIApplication *app = [UIApplication sharedApplication];
    LokaliteAppDelegate *appDelegate = (LokaliteAppDelegate *) [app delegate];

    [appDelegate displayActivityViewAnimated:animated completion:completion];
    [app networkActivityIsStarting];
}

- (void)hideActivityAnimated:(BOOL)animated
                  completion:(void(^)(void))completion
{
    UIApplication *app = [UIApplication sharedApplication];
    LokaliteAppDelegate *appDelegate = (LokaliteAppDelegate *) [app delegate];

    [appDelegate hideActivityViewAnimated:animated completion:completion];
    [app networkActivityDidFinish];
}

- (void)cancelModalWebViewAnimated:(BOOL)animated
                        completion:(void (^)(void))completion
{
    [self dismissModalViewControllerAnimated:animated];
    if (completion) {
        if (animated) {
            completion = [[completion copy] autorelease];
            [self performSelector:@selector(performBlock:)
                       withObject:completion
                       afterDelay:0.3];
        } else
            completion();
    }
}

// crap helper method to call this method after a delay
- (void)performBlock:(void (^)(void))completion
{
    completion();
}

- (void)presentError:(NSError *)error
{
    NSString *title = NSLocalizedString(@"twitter.oauth.failed.title", nil);
    NSString *message = [error localizedDescription];
    NSString *cancelButtonTitle = NSLocalizedString(@"global.dismiss", nil);

    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:title
                                   message:message
                                  delegate:nil
                         cancelButtonTitle:cancelButtonTitle
                         otherButtonTitles:nil];

    [alert show];
    [alert release], alert = nil;
}

#pragma mark - Accessors

- (TwitterOAuthAuthenticator *)authenticator
{
    if (!authenticator_) {
        NSString *key = LokaliteTwitterOAuthConsumerKey;
        NSString *secret = LokaliteTwitterOAuthConsumerSecret;
        authenticator_ =
            [[TwitterOAuthAuthenticator alloc] initWithConsumerKey:key
                                                    consumerSecret:secret];
        [authenticator_ setDelegate:self];
    }

    return authenticator_;
}

- (UIViewController *)modalWebViewControllerForUrl:(NSURL *)url
{
    NSString *callbackUrlString = LokaliteTwitterOAuthTokenCallbackUrl;
    NSURL *callbackUrl = [NSURL URLWithString:callbackUrlString];
    TwitterOAuthWebView *webView =
        [[TwitterOAuthWebView alloc] initWithUrl:url callbackUrl:callbackUrl];
    [webView setDelegate:self];

    UINavigationController *nc =
        [[UINavigationController alloc] initWithRootViewController:webView];
    [[nc navigationBar]
     setTintColor:[[[self navigationController] navigationBar] tintColor]];

    [webView setTitle:NSLocalizedString(@"twitter.authorize", nil)];

    UIBarButtonItem *cancelButtonItem =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                              target:self
                              action:@selector(cancelModalWebView:)];
    [[webView navigationItem] setLeftBarButtonItem:cancelButtonItem];
    [cancelButtonItem release], cancelButtonItem = nil;

    [webView release], webView = nil;

    return [nc autorelease];
}

@end
