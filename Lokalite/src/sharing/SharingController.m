//
//  SharingController.m
//  Lokalite
//
//  Created by John Debay on 8/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "SharingController.h"

#import "LokaliteAppDelegate.h"

#import "SBJSON.h"

@interface SharingController ()

@property (nonatomic, retain) NSMutableDictionary *actions;

@property (nonatomic, retain) Facebook *facebook;

- (void)mapOptionIndex:(NSInteger)index toAction:(SEL)action;
- (void)presentSharingOptions;

#pragma mark - Facebook

- (void)logInToFacebook;
- (void)sendObjectToFacebook;

#pragma mark - Accessors

- (UIViewController *)hostViewController;

@end


@implementation SharingController

@synthesize shareableObject = shareableObject_;
@synthesize actions = actions_;
@synthesize facebook = facebook_;

#pragma mark - Memory management

- (void)dealloc
{
    [shareableObject_ release];
    [actions_ release];
    [facebook_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithShareableObject:(id<ShareableObject>)object
{
    self = [super init];
    if (self)
        shareableObject_ = [object retain];

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
    if ([[self facebook] accessToken])
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
    /*
    SBJSON *jsonWriter = [[SBJSON new] autorelease];

  NSDictionary* actionLinks = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObjectsAndKeys:
                               @"Always Running",@"text",@"http://itsti.me/",@"href", nil], nil];

  NSString *actionLinksStr = [jsonWriter stringWithObject:actionLinks];
  NSDictionary* attachment = [NSDictionary dictionaryWithObjectsAndKeys:
                               @"a long run", @"name",
                               @"The Facebook Running app", @"caption",
                               @"it is fun", @"description",
                               @"http://itsti.me/", @"href", nil];
  NSString *attachmentStr = [jsonWriter stringWithObject:attachment];
  NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                 @"Share on Facebook",  @"user_message_prompt",
                                 actionLinksStr, @"action_links",
                                 attachmentStr, @"attachment",
                                 nil];
     */


    NSMutableDictionary *params =
        [NSMutableDictionary dictionaryWithObjectsAndKeys:
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
    [self sendObjectToFacebook];
}

#pragma mark - FBDialogDelegate implementation

- (void)dialogDidComplete:(FBDialog *)dialog
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)dialogCompleteWithUrl:(NSURL *)url
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)dialogDidNotCompleteWithUrl:(NSURL *)url
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)dialogDidNotComplete:(FBDialog *)dialog
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (void)dialog:(FBDialog*)dialog didFailWithError:(NSError *)error
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
}

- (BOOL)dialog:(FBDialog*)dialog shouldOpenURLInExternalBrowser:(NSURL *)url
{
    return YES;
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
    if (!facebook_)
        facebook_ = [[Facebook alloc] initWithAppId:@"206217952760561"
                                        andDelegate:self];

    return facebook_;
}

@end
