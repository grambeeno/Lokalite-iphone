//
//  SharingController.m
//  Lokalite
//
//  Created by John Debay on 8/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "SharingController.h"

#import "LokaliteAppDelegate.h"

@interface SharingController ()

@property (nonatomic, retain) NSMutableDictionary *actions;

- (void)mapOptionIndex:(NSInteger)index toAction:(SEL)action;
- (void)presentSharingOptions;

#pragma mark - Accessors

- (UIViewController *)hostViewController;

@end


@implementation SharingController

@synthesize shareableObject = shareableObject_;
@synthesize actions = actions_;

#pragma mark - Memory management

- (void)dealloc
{
    [shareableObject_ release];
    [actions_ release];

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

    [options addObject:NSLocalizedString(@"global.post-to-facebook", nil)];
    [self mapOptionIndex:index++ toAction:@selector(shareWithFacebook)];

    [options addObject:NSLocalizedString(@"global.post-to-twitter", nil)];
    [self mapOptionIndex:index++ toAction:@selector(shareWithTwitter)];

    if ([MFMailComposeViewController canSendMail]) {
        [options addObject:NSLocalizedString(@"global.send-email", nil)];
        [self mapOptionIndex:index++ toAction:@selector(shareWithEmail)];
    }

    if ([MFMessageComposeViewController canSendText]) {
        [options addObject:NSLocalizedString(@"global.send-text-message", nil)];
        [self mapOptionIndex:index++ toAction:@selector(shareWithSMS)];
    }

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
    NSLog(@"%d", buttonIndex);

    if (buttonIndex != [actionSheet cancelButtonIndex]) {
        SEL action = [self actionAtIndex:buttonIndex];
        [self performSelector:action];
    }
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

#pragma mark - Accessors

- (UIViewController *)hostViewController
{
    LokaliteAppDelegate *appDelegate =
        (LokaliteAppDelegate *) [[UIApplication sharedApplication] delegate];
    return [appDelegate tabBarController];
}

@end
