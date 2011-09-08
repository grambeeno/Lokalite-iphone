//
//  SettingsViewController.m
//  Lokalite
//
//  Created by John Debay on 8/27/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "SettingsViewController.h"

#import "Facebook.h"
#import "Facebook+GeneralHelpers.h"

#import "TwitterAccount.h"
#import "TwitterAccount+GeneralHelpers.h"

#import "TwitterOAuthLogInViewController.h"

#import "LokaliteAppDelegate.h"

#import "NSUserDefaults+GeneralHelpers.h"

#import <CoreData/CoreData.h>

enum {
    kSectionLocalNotifications,
    kSectionFacebook,
    kSectionTwitter
};
static const NSInteger NUM_SECTIONS = kSectionTwitter + 1;

enum {
    kLocalNotificationRowPromptWhenTrending
};
static const NSInteger NUM_LOCAL_NOTIFICATION_ROWS =
    kLocalNotificationRowPromptWhenTrending + 1;

enum {
    // logged out
    kFacebookLogIn,

    // logged in
    kFacebookUsername = kFacebookLogIn,
    kFacebookLogOut
};
static const NSInteger NUM_FACEBOOK_LOGGED_OUT_ROWS = kFacebookLogIn + 1;
static const NSInteger NUM_FACEBOOK_LOGGED_IN_ROWS = kFacebookLogOut + 1;

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

#pragma mark - Facebook methods

@property (nonatomic, retain) Facebook *facebook;
@property (nonatomic, retain) UIActionSheet *facebookActionSheet;

- (void)logInToFacebook;
- (void)promptToLogOutOfFacebook;
- (void)logOutOfFacebook;

#pragma mark - Twitter methods

@property (nonatomic, retain) UIActionSheet *twitterActionSheet;

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

@synthesize facebook = facebook_;
@synthesize facebookActionSheet = facebookActionSheet_;

@synthesize twitterActionSheet = twitterActionSheet_;

@synthesize promptWhenTrendingCell = promptWhenTrendingCell_;
@synthesize promptWhenTrendingSwitch = promptWhenTrendingSwitch_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [context_ release];

    [facebook_ release];
    [facebookActionSheet_ release];
    [twitterActionSheet_ release];

    [promptWhenTrendingCell_ release];
    [promptWhenTrendingSwitch_ release];

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

- (IBAction)promptWhenTrendingValueChanged:(UISwitch *)sender
{
    BOOL on = [[self promptWhenTrendingSwitch] isOn];
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setPromptForLocalNotificationWhenTrending:on];

    if (!on)
        [[UIApplication sharedApplication] cancelAllLocalNotifications];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeNavigationItem:[self navigationItem]];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL prompt = [defaults promptForLocalNotificationWhenTrending];
    [[self promptWhenTrendingSwitch] setOn:prompt];
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

    if (section == kSectionLocalNotifications)
        nrows = NUM_LOCAL_NOTIFICATION_ROWS;
    else if (section == kSectionFacebook) {
        if ([[self facebook] isSessionValid])
            nrows = NUM_FACEBOOK_LOGGED_IN_ROWS;
        else
            nrows = NUM_FACEBOOK_LOGGED_OUT_ROWS;
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

    if (section == kSectionLocalNotifications)
        title = NSLocalizedString(@"global.alerts", nil);
    if (section == kSectionFacebook)
        title = NSLocalizedString(@"global.facebook", nil);
    else if (section == kSectionTwitter)
        title = NSLocalizedString(@"global.twitter", nil);

    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    if ([indexPath section] == kSectionLocalNotifications &&
        [indexPath row] == kLocalNotificationRowPromptWhenTrending) {
        cell = [self promptWhenTrendingCell];
    } else {
        static NSString *CellIdentifier = @"Cell";

        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell =
                [[[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleValue1
                  reuseIdentifier:CellIdentifier] autorelease];
        }

        if ([indexPath section] == kSectionFacebook) {
            Facebook *facebook = [self facebook];
            if ([facebook isSessionValid]) {
                if ([indexPath row] == kFacebookUsername) {
                    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    [[cell textLabel] setTextAlignment:UITextAlignmentLeft];

                    [[cell textLabel]
                     setText:NSLocalizedString(@"facebook.status", nil)];
                [[cell detailTextLabel]
                 setText:NSLocalizedString(@"facebook.connected", nil)];
                } else if ([indexPath row] == kFacebookLogOut) {
                    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    [[cell textLabel] setTextAlignment:UITextAlignmentCenter];

                    [[cell textLabel]
                     setText:NSLocalizedString(@"facebook.log-out.title", nil)];
                    [[cell detailTextLabel] setText:nil];
                }
            } else {
                if ([indexPath row] == kFacebookLogIn) {
                    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    [[cell textLabel] setTextAlignment:UITextAlignmentCenter];

                    [[cell textLabel]
                     setText:NSLocalizedString(@"facebook.log-in.title", nil )];
                    [[cell detailTextLabel] setText:nil];
                }
            }
        } else if ([indexPath section] == kSectionTwitter) {
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
                if ([indexPath row] == kTwitterLogIn) {
                    [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
                    [cell setAccessoryType:UITableViewCellAccessoryNone];
                    [[cell textLabel] setTextAlignment:UITextAlignmentCenter];

                    [[cell textLabel]
                     setText:NSLocalizedString(@"twitter.log-in.title", nil)];
                    [[cell detailTextLabel] setText:nil];
                }
            }
        }
    }

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == kSectionFacebook) {
        if ([[self facebook] isSessionValid]) {
            if ([indexPath row] == kFacebookLogOut) {
                [self promptToLogOutOfFacebook];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        } else {
            if ([indexPath row] == kFacebookLogIn) {
                [self logInToFacebook];
                [tableView deselectRowAtIndexPath:indexPath animated:YES];
            }
        }
    } else if ([indexPath section] == kSectionTwitter) {
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
    if ([self facebookActionSheet] == actionSheet && buttonIndex == 0) {
        // facebook log out confirmed
        [self logOutOfFacebook];

        NSIndexSet *sections = [NSIndexSet indexSetWithIndex:kSectionFacebook];
        [[self tableView] reloadSections:sections
                        withRowAnimation:UITableViewRowAnimationFade];

        [self setFacebookActionSheet:nil];
    }
    if ([self twitterActionSheet] == actionSheet &&  buttonIndex == 0) {
        // twitter log out confirmed
        [self logOutOfTwitter];

        NSIndexSet *sections = [NSIndexSet indexSetWithIndex:kSectionTwitter];
        [[self tableView] reloadSections:sections
                        withRowAnimation:UITableViewRowAnimationFade];

        [self setTwitterActionSheet:nil];
    }
}

#pragma mark - Facebook methods

- (void)logInToFacebook
{
    NSArray *permissions = [Facebook defaultPermissions];
    [[self facebook] authorize:permissions localAppId:nil safariAuth:NO];
}

- (void)promptToLogOutOfFacebook
{
    NSString *cancelButtonTitle = NSLocalizedString(@"global.cancel", nil);
    NSString *destructiveButtonTitle =
        NSLocalizedString(@"facebook.log-out.title", nil);

    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:cancelButtonTitle
                      destructiveButtonTitle:destructiveButtonTitle
                           otherButtonTitles:nil];

    LokaliteAppDelegate *delegate = (LokaliteAppDelegate *)
        [[UIApplication sharedApplication] delegate];
    [sheet showFromTabBar:[[delegate tabBarController] tabBar]];

    [self setFacebookActionSheet:sheet];
    [sheet release], sheet = nil;
}

- (void)logOutOfFacebook
{
    [[self facebook] logout:self];
}

#pragma mark - FBSessionDelegate implementation

- (void)fbDidLogin
{
    [[self facebook] saveSession];

    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:kSectionFacebook];
    [[self tableView] reloadSections:sections
                    withRowAnimation:UITableViewRowAnimationFade];

    [self setFacebookActionSheet:nil];
}

- (void)fbDidLogout
{
    [[self facebook] saveSession];
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

    [self setTwitterActionSheet:sheet];
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

- (Facebook *)facebook
{
    if (!facebook_) {
        facebook_ = [[Facebook alloc] initWithAppId:LokaliteFacebookAppId
                                        andDelegate:self];
        [facebook_ restoreSession];
    }

    return facebook_;
}

- (TwitterAccount *)twitterAccount
{
    return [TwitterAccount accountInContext:[self context]];
}

@end
