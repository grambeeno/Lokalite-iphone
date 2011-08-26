//
//  SharingController.m
//  Lokalite
//
//  Created by John Debay on 8/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "SharingController.h"

#import "LokaliteAppDelegate.h"

#import "Facebook+GeneralHelpers.h"

#import "TwitterAccount.h"
#import "TwitterAccount+GeneralHelpers.h"
#import "TwitterOAuthLogInViewController.h"
#import "ComposeTweetViewController.h"

#import "UIApplication+GeneralHelpers.h"

#import "SBJSON.h"

@interface SharingController ()

@property (nonatomic, retain) NSMutableDictionary *actions;

- (void)mapOptionIndex:(NSInteger)index toAction:(SEL)action;
- (void)presentSharingOptions;

#pragma mark - Facebook

@property (nonatomic, retain) Facebook *facebook;

- (void)logInToFacebook;
- (void)sendObjectToFacebook;

#pragma mark - Twitter

@property (nonatomic, retain) TwitterService *twitter;

- (void)presentTweetComposeViewWithAccount:(TwitterAccount *)account
                            hostController:(UIViewController *)hostController
                                  animated:(BOOL)animated;
- (void)sendTweetText:(NSString *)text account:(TwitterAccount *)account;

#pragma mark - Accessors

- (UIViewController *)hostViewController;

@end


@implementation SharingController

@synthesize shareableObject = shareableObject_;
@synthesize context = context_;

@synthesize actions = actions_;
@synthesize facebook = facebook_;
@synthesize twitter = twitter_;

#pragma mark - Memory management

- (void)dealloc
{
    [shareableObject_ release];
    [context_ release];

    [actions_ release];
    [facebook_ release];
    [twitter_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithShareableObject:(id<ShareableObject>)object
                      context:(NSManagedObjectContext *)context
{
    self = [super init];
    if (self) {
        shareableObject_ = [object retain];
        context_ = [context retain];
    }

    return self;
}

- (void)share
{
    [self presentSharingOptions];
}

#pragma mark - UI helpers

- (void)mapOptionIndex:(NSInteger)index toAction:(SEL)action
{
    [[self actions] setObject:NSStringFromSelector(action)
                       forKey:[NSNumber numberWithInteger:index]];
}

- (SEL)actionAtIndex:(NSInteger)index
{
    NSString *name =
        [[self actions] objectForKey:[NSNumber numberWithInteger:index]];

    return NSSelectorFromString(name);
}

- (void)presentSharingOptions
{
    NSString *title = nil;
    NSString *cancelButtonTitle = NSLocalizedString(@"global.cancel", nil);

    NSMutableArray *options = [NSMutableArray array];
    [self setActions:[NSMutableDictionary dictionary]];

    NSInteger index = 0;

    [options addObject:NSLocalizedString(@"global.open-in-safari", nil)];
    [self mapOptionIndex:index++ toAction:@selector(shareWithSafari)];

    if ([MFMailComposeViewController canSendMail]) {
        [options addObject:NSLocalizedString(@"global.send-email", nil)];
        [self mapOptionIndex:index++ toAction:@selector(shareWithEmail)];
    }

    if ([MFMessageComposeViewController canSendText]) {
        [options addObject:NSLocalizedString(@"global.send-text-message", nil)];
        [self mapOptionIndex:index++ toAction:@selector(shareWithSMS)];
    }

    [options addObject:NSLocalizedString(@"global.post-to-facebook", nil)];
    [self mapOptionIndex:index++ toAction:@selector(shareWithFacebook)];

    [options addObject:NSLocalizedString(@"global.post-to-twitter", nil)];
    [self mapOptionIndex:index++ toAction:@selector(shareWithTwitter)];

    [options addObject:cancelButtonTitle];

    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:title
                                    delegate:self
                           cancelButtonTitle:nil
                      destructiveButtonTitle:nil
                           otherButtonTitles:nil];

    [options enumerateObjectsUsingBlock:
     ^(NSString *title, NSUInteger idx, BOOL *stop) {
        [sheet addButtonWithTitle:title];
    }];
    [sheet setCancelButtonIndex:[options count] - 1];

    LokaliteAppDelegate *appDelegate =
        (LokaliteAppDelegate *) [[UIApplication sharedApplication] delegate];
    UITabBar *tabBar = [[appDelegate tabBarController] tabBar];
    [sheet showFromTabBar:tabBar];
    [sheet release], sheet = nil;
}

#pragma mark - UIActionSheetDelegate implementation

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        SEL action = [self actionAtIndex:buttonIndex];
        [self performSelector:action];
    }
}

#pragma mark - Sharing via Safari

- (void)shareWithSafari
{
    NSURL *url = [[self shareableObject] lokaliteUrl];
    [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Sharing via email

- (void)shareWithEmail
{
    MFMailComposeViewController *controller =
        [[MFMailComposeViewController alloc] init];
    [controller setMailComposeDelegate:self];
    [controller setSubject:[[self shareableObject] emailSubject]];
    [controller setMessageBody:[[self shareableObject] emailHTMLBody]
                        isHTML:YES];

    [[self hostViewController] presentModalViewController:controller
                                                 animated:YES];
    [controller release], controller = nil;
}

#pragma mark - MFMailComposeViewControllerDelegate implementation

- (void)mailComposeController:(MFMailComposeViewController*)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError*)error
{
    [[self hostViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - Sharing via SMS

- (void)shareWithSMS
{
    MFMessageComposeViewController *controller =
        [[MFMessageComposeViewController alloc] init];
    [controller setMessageComposeDelegate:self];
    [controller setBody:[[self shareableObject] smsBody]];

    [[self hostViewController] presentModalViewController:controller
                                                 animated:YES];

    [controller release], controller = nil;
}

#pragma mark - MFMessageComposeViewControllerDelegate implementation

- (void)messageComposeViewController:(MFMessageComposeViewController *)ctlr
                 didFinishWithResult:(MessageComposeResult)result
{
    [[self hostViewController] dismissModalViewControllerAnimated:YES];
}

#pragma mark - Sharing via Facebook

- (void)shareWithFacebook
{
    NSLog(@"Is session valid: %@", [[self facebook] isSessionValid] ? @"YES" : @"NO");
    NSLog(@"access token: '%@'", [[self facebook] accessToken]);
    NSLog(@"Expiration date: '%@'", [[self facebook] expirationDate]);

    if ([[self facebook] isSessionValid])
        [self sendObjectToFacebook];
    else
        [self logInToFacebook];
}

- (void)logInToFacebook
{
    NSArray *permissions = [NSArray arrayWithObject:@"publish_stream"];
    [[self facebook] authorize:permissions localAppId:nil safariAuth:NO];
    NSLog(@"Token before logging in: %@", [[self facebook] accessToken]);
}

- (void)sendObjectToFacebook
{
    //
    // for a list of supported arguments, see:
    //   http://developers.facebook.com/docs/reference/dialogs/feed/
    //
    NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
         [[self shareableObject] facebookName], @"name",
         [[[self shareableObject] lokaliteUrl] absoluteString], @"link",
         [[[self shareableObject] facebookImageUrl] absoluteString], @"picture",
         [[self shareableObject] facebookCaption], @"caption",
         [[self shareableObject] facebookDescription], @"description",
         nil];
    [[self facebook] dialog:@"feed" andParams:params andDelegate:self];
}

#pragma mark - FBSessionDelegate implementation

/**
 * Called when the user successfully logged in.
 */
- (void)fbDidLogin
{
    [[self facebook] saveSession];
    [self sendObjectToFacebook];
}

- (void)fbDidLogout
{
    [[self facebook] saveSession];
}

#pragma mark - Twitter

- (void)shareWithTwitter
{
    NSManagedObjectContext *context = [self context];

    TwitterAccount *account = [TwitterAccount accountInContext:context];
    if (!account) {
        TwitterOAuthLogInViewController *controller =
            [[TwitterOAuthLogInViewController alloc] init];
        UINavigationController *nc =
            [[UINavigationController alloc]
             initWithRootViewController:controller];

        [controller setLogInDidSucceedHandler:
         ^(NSNumber *uid, NSString *user, NSString *token, NSString *secret) {
             TwitterAccount *account =
                [TwitterAccount setAccountWithUserId:uid
                                            username:user
                                               token:token
                                              secret:secret
                                             context:context];

             //UIViewController *hostController =
             //   [nc modalViewController] ? [nc modalViewController] : nc;
             [self presentTweetComposeViewWithAccount:account
                                       hostController:nc
                                             animated:YES];
         }];

        [[self hostViewController] presentModalViewController:nc animated:YES];

        [nc release];
        [controller release];
    } else
        [self presentTweetComposeViewWithAccount:account
                                  hostController:[self hostViewController]
                                        animated:YES];
}

- (void)presentTweetComposeViewWithAccount:(TwitterAccount *)account
                            hostController:(UIViewController *)hostController
                                  animated:(BOOL)animated
{
    UIViewController *rootController = [self hostViewController];
    ComposeTweetViewController *controller =
        [[ComposeTweetViewController alloc]
         initWithTwitterAccount:account shareableObject:[self shareableObject]];
    [controller setDidCancelHandler:^{
        [rootController dismissModalViewControllerAnimated:YES];
    }];
    [controller setShouldSendHandler:^(NSString *text) {
        NSLog(@"Sending tweet text: %@", text);
        [self sendTweetText:text account:account];
    }];

    UINavigationController *nc =
        [[UINavigationController alloc] initWithRootViewController:controller];

    [hostController presentModalViewController:nc animated:YES];

    [nc release], nc = nil;
    [controller release], controller = nil;
}

- (void)sendTweetText:(NSString *)text account:(TwitterAccount *)account
{
    [[UIApplication sharedApplication] networkActivityIsStarting];

    TwitterService *twitter =
        [[TwitterService alloc] initWithTwitterAccount:account];
    [twitter setDelegate:self];

    [twitter sendTweetWithText:text];

    [self setTwitter:twitter];
    [twitter release], twitter = nil;
}

#pragma mark - TwitterServiceDelegate implementation

- (void)twitterService:(TwitterService *)service
          didSendTweet:(NSDictionary *)tweetData
{
    [[UIApplication sharedApplication] networkActivityDidFinish];
    [[self hostViewController] dismissModalViewControllerAnimated:YES];
}

- (void)twitterService:(TwitterService *)service
    didFailToSendTweet:(NSError *)error
{
    [[UIApplication sharedApplication] networkActivityDidFinish];

    NSString *title =
        NSLocalizedString(@"twitter.send-failed.error.title", nil);
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

- (UIViewController *)hostViewController
{
    LokaliteAppDelegate *appDelegate =
        (LokaliteAppDelegate *) [[UIApplication sharedApplication] delegate];
    return [appDelegate tabBarController];
}

- (Facebook *)facebook
{
    if (!facebook_) {
        facebook_ = [[Facebook alloc] initWithAppId:@"206217952760561"
                                        andDelegate:self];
        [facebook_ restoreSession];
    }

    return facebook_;
}

@end
