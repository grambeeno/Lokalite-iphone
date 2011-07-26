//
//  AccountDetailsViewController.m
//  Lokalite
//
//  Created by John Debay on 7/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "AccountDetailsViewController.h"

@interface AccountDetailsViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem:(UINavigationItem *)navItem;

@end


@implementation AccountDetailsViewController

@synthesize delegate = delegate_;
@synthesize account = account_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [account_ release];
    
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

    [self initializeNavigationItem:[self navigationItem]];
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 0;
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
    }

    return cell;
}

#pragma mark - View initialization

- (void)initializeNavigationItem:(UINavigationItem *)navItem
{
    NSString *logOutTitle = NSLocalizedString(@"global.log-out", nil);
    UIBarButtonItem *logOutButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:logOutTitle
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(logOut:)];
    [navItem setRightBarButtonItem:logOutButtonItem];
    [logOutButtonItem release], logOutButtonItem = nil;
}

@end
