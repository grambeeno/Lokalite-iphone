//
//  SettingsViewController.m
//  Lokalite
//
//  Created by John Debay on 8/27/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "SettingsViewController.h"

#import "TwitterAccount.h"
#import "TwitterAccount+GeneralHelpers.h"

#import "TwitterOAuthLogInViewController.h"

#import "LokaliteAppDelegate.h"

#import <CoreData/CoreData.h>

enum {
    kSectionFacebook,
    kSectionTwitter
};
static const NSInteger NUM_SECTIONS = kSectionTwitter + 1;

enum {
    // logged out
    kTwitterLogIn,

    // logged in
    kTwitterUsername = kTwitterLogIn,
    kTwitterLogOut
};
static const NSInteger NUM_TWITTER_LOGGED_OUT_ROWS = kTwitterLogIn + 1;
static const NSInteger NUM_TWITTER_LOGGED_IN_ROWS = kTwitterLogOut + 1;

@interface SettingsViewController ()

#pragma mark - Twitter methods

- (void)logInToTwitter;
- (void)promptToLogOutOfTwitter;
- (void)logOutOfTwitter;

#pragma mark - View initialization

- (void)initializeNavigationItem:(UINavigationItem *)navigationItem;

#pragma mark - Accessors

- (TwitterAccount *)twitterAccount;

@end


@implementation SettingsViewController

@synthesize delegate = delegate_;
@synthesize context = context_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [context_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:@"SettingsView" bundle:nil];
    if (self) {
        context_ = [context retain];
        [self setTitle:NSLocalizedString(@"global.settings", nil)];
    }

    return self;
}

#pragma mark - UI events

- (void)done:(id)sender
{
    [[self delegate] settingsViewControllerIsDone:self];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeNavigationItem:[self navigationItem]];
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger nrows = 0;

    if (section == kSectionFacebook) {
        nrows = 0;
    } else if (section == kSectionTwitter) {
        if ([self twitterAccount])
            nrows = NUM_TWITTER_LOGGED_IN_ROWS;
        else
            nrows = NUM_TWITTER_LOGGED_OUT_ROWS;
    }

    return nrows;
}

- (NSString *)tableView:(UITableView *)tableView
    titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;

    if (section == kSectionFacebook)
        title = NSLocalizedString(@"global.facebook", nil);
    else if (section == kSectionTwitter)
        title = NSLocalizedString(@"global.twitter", nil);

    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell =
            [[[UITableViewCell alloc]
              initWithStyle:UITableViewCellStyleValue1
              reuseIdentifier:CellIdentifier] autorelease];
    }

    if ([indexPath section] == kSectionTwitter) {
        TwitterAccount *account = [self twitterAccount];
        if (account) {
            if ([indexPath row] == kTwitterUsername) {
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [[cell textLabel] setTextAlignment:UITextAlignmentLeft];

                [[cell textLabel]
                 setText:NSLocalizedString(@"twitter.username", nil)];
                [[cell detailTextLabel] setText:[account username]];
            } else if ([indexPath row] == kTwitterLogOut) {
                [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [[cell textLabel] setTextAlignment:UITextAlignmentCenter];

                [[cell textLabel]
                 setText:NSLocalizedString(@"twitter.log-out.title", nil)];
                [[cell detailTextLabel] setText:nil];
            }
        } else {
            if ([indexPath row] == kTwitterLogIn)
                [[cell textLabel]
                 setText:NSLocalizedString(@"twitter.log-in.title", nil)];
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == kSectionTwitter) {
        if ([self twitterAccount]) {
            if ([indexPath row] == kTwitterLogOut) {
                [self promptToLogOutOfTwitter];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        } else {
            if ([indexPath row] == kTwitterLogIn) {
                [self logInToTwitter];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    }
}

#pragma mark - UIActionSheetDelegate implementation

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {  // log out confirmed
        [self logOutOfTwitter];
        NSIndexSet *sections = [NSIndexSet indexSetWithIndex:kSectionTwitter];
        [[self tableView] reloadSections:sections
                        withRowAnimation:UITableViewRowAnimationFade];
    }
}

#pragma mark - Twitter methods

- (void)logInToTwitter
{
    NSManagedObjectContext *context = [self context];
    UITableView *tableView = [self tableView];

    TwitterOAuthLogInViewController *controller =
        [[TwitterOAuthLogInViewController alloc] init];
    UINavigationController *nc =
        [[UINavigationController alloc] initWithRootViewController:controller];
    [[nc navigationBar]
     setTintColor:[[[self navigationController] navigationBar] tintColor]];
    
    [controller setLogInDidSucceedHandler:
     ^(NSNumber *uid, NSString *user, NSString *token, NSString *secret) {
         [TwitterAccount setAccountWithUserId:uid
                                     username:user
                                        token:token
                                       secret:secret
                                      context:context];

         NSIndexSet *sections = [NSIndexSet indexSetWithIndex:kSectionTwitter];
         [tableView reloadSections:sections
                  withRowAnimation:UITableViewRowAnimationFade];

         [self dismissModalViewControllerAnimated:YES];
     }];

    [self presentModalViewController:nc animated:YES];

    [nc release], nc = nil;
    [controller release], controller = nil;
}

- (void)promptToLogOutOfTwitter
{
    NSString *cancelButtonTitle = NSLocalizedString(@"global.cancel", nil);
    NSString *destructiveButtonTitle =
        NSLocalizedString(@"twitter.log-out.title", nil);

    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:cancelButtonTitle
                      destructiveButtonTitle:destructiveButtonTitle
                           otherButtonTitles:nil];

    LokaliteAppDelegate *delegate = (LokaliteAppDelegate *)
        [[UIApplication sharedApplication] delegate];
    [sheet showFromTabBar:[[delegate tabBarController] tabBar]];
    [sheet release], sheet = nil;
}

- (void)logOutOfTwitter
{
    NSLog(@"Logging out of Twitter account '%@'",
          [[self twitterAccount] username]);
    [[self context] deleteObject:[self twitterAccount]];
}

#pragma mark - View initialization

- (void)initializeNavigationItem:(UINavigationItem *)navigationItem
{
    UIBarButtonItem *doneButton =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemDone
         target:self action:@selector(done:)];
    [navigationItem setRightBarButtonItem:doneButton];
    [doneButton release], doneButton = nil;
}

#pragma mark - Accessors

- (TwitterAccount *)twitterAccount
{
    return [TwitterAccount accountInContext:[self context]];
}

@end
