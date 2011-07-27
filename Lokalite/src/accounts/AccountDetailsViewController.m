//
//  AccountDetailsViewController.m
//  Lokalite
//
//  Created by John Debay on 7/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "AccountDetailsViewController.h"

#import "LokaliteAccount.h"

enum {
    kSectionAccountDetails
};
static const NSInteger NUM_SECTIONS = kSectionAccountDetails + 1;

enum {
    kAccountDetailsRowEmail,
    kAccountDetailsRowCreationDate
};
static const NSInteger NUM_ACCOUNT_DETAILS_ROWS =
    kAccountDetailsRowCreationDate + 1;


@interface AccountDetailsViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem;
- (void)initializeTableView;

#pragma mark - View configuration

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path;

@end


@implementation AccountDetailsViewController

@synthesize delegate = delegate_;
@synthesize account = account_;
@synthesize headerView = headerView_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [account_ release];

    [headerView_ release];
    
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithAccount:(LokaliteAccount *)account
{
    self = [super initWithNibName:@"AccountDetailsView" bundle:nil];
    if (self) {
        account_ = [account retain];
        [self setTitle:NSLocalizedString(@"global.profile", nil)];
    }

    return self;
}

#pragma mark - UI events

- (void)logOut:(id)sender
{
    [[self delegate] accountDetailsViewController:self
                                    logOutAccount:[self account]];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];
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

    if (section == 0)
        nrows = NUM_ACCOUNT_DETAILS_ROWS;

    return nrows;
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;

    if (section == kSectionAccountDetails)
        title = NSLocalizedString(@"global.account-details", nil);

    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell =
            [[[UITableViewCell alloc]
              initWithStyle:UITableViewCellStyleValue2
              reuseIdentifier:CellIdentifier] autorelease];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    UINavigationItem *navItem = [self navigationItem];

    NSString *logOutTitle = NSLocalizedString(@"global.log-out", nil);
    UIBarButtonItem *logOutButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:logOutTitle
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(logOut:)];
    [navItem setRightBarButtonItem:logOutButtonItem];
    [logOutButtonItem release], logOutButtonItem = nil;
}

- (void)initializeTableView
{
    [[self tableView] setTableHeaderView:[self headerView]];
}

#pragma mark - View configuration

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path
{
    if ([path section] == kSectionAccountDetails) {
        NSString *text = nil, *detailText = nil;

        if ([path row] == kAccountDetailsRowEmail) {
            text = NSLocalizedString(@"global.email", nil);
            detailText = [[self account] email];
        } else if ([path row] == kAccountDetailsRowCreationDate) {
            text = NSLocalizedString(@"global.registered", nil);

            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setLocale:[NSLocale currentLocale]];
            [formatter setDateStyle:NSDateFormatterLongStyle];
            [formatter setTimeStyle:NSDateFormatterNoStyle];
            detailText =
                [formatter stringFromDate:[[self account] creationDate]];
            [formatter release], formatter = nil;
        }

        [[cell textLabel] setText:text];
        [[cell detailTextLabel] setText:detailText];

        [cell setAccessoryType:UITableViewCellAccessoryNone];
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}

@end
