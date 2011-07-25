//
//  ProfileViewController.m
//  Lokalite
//
//  Created by John Debay on 7/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "ProfileViewController.h"

enum {
    kSectionUserActions,
    kSectionMetaActions
};
static const NSInteger NUM_SECTIONS = kSectionMetaActions + 1;

enum {
    kUserActionLogInRow,
    kUserActionSignUpRow
};
static const NSInteger NUM_USER_ACTION_ROWS = kUserActionSignUpRow + 1;

enum {
    kMetaActionLearnMoreRow,
    kMetaActionHelpRow
};
static const NSInteger NUM_META_ACTION_ROWS = kMetaActionHelpRow + 1;


@interface ProfileViewController ()

#pragma mark - View initialization

- (void)initializeTableView:(UITableView *)tableView;

@end


@implementation ProfileViewController

@synthesize headerView = headerView_;

#pragma mark - Memory management

- (void)dealloc
{
    [headerView_ release];
    [super dealloc];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeTableView:[self tableView]];
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
    if (section == kSectionUserActions)
        nrows = NUM_USER_ACTION_ROWS;
    else if (section == kSectionMetaActions)
        nrows = NUM_META_ACTION_ROWS;

    return nrows;
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
              initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:CellIdentifier] autorelease];
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
        [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
    }

    NSString *labelText = nil;

    if ([indexPath section] == kSectionUserActions) {
        if ([indexPath row] == kUserActionLogInRow)
            labelText = NSLocalizedString(@"global.log-in", nil);
        else if ([indexPath row] == kUserActionSignUpRow)
            labelText = NSLocalizedString(@"global.sign-up", nil);
    } else if ([indexPath section] == kSectionMetaActions) {
        if ([indexPath row] == kMetaActionLearnMoreRow)
            labelText = NSLocalizedString(@"global.learn-more", nil);
        else if ([indexPath row] == kMetaActionHelpRow)
            labelText = NSLocalizedString(@"global.help", nil);
    }

    [[cell textLabel] setText:labelText];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UIViewController *c = nil;

    if ([indexPath section] == kSectionUserActions) {
        if ([indexPath row] == kUserActionLogInRow) {
            LogInViewController *livc =
                [[[LogInViewController alloc] init] autorelease];
            [livc setDelegate:self];
            c = livc;
        } else if ([indexPath row] == kUserActionSignUpRow) {

        }
    } else if ([indexPath section] == kSectionMetaActions) {
        if ([indexPath row] == kMetaActionLearnMoreRow) {
        } else if ([indexPath row] == kMetaActionHelpRow) {
        }
    }

    if (c) {
        UINavigationController *nc =
            [[UINavigationController alloc] initWithRootViewController:c];
        [self presentModalViewController:nc animated:YES];
        [nc release], nc = nil;
    } else
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - LogInViewControllerDelegate implementation

- (void)logInViewController:(LogInViewController *)controller
       didLogInWithUsername:(NSString *)username
                   password:(NSString *)password
{
}

- (void)logInViewControllerDidCancel:(LogInViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View initialization

- (void)initializeTableView:(UITableView *)tableView
{
    [tableView setTableHeaderView:[self headerView]];
}

@end
