//
//  EventDetailsViewController.m
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventDetailsViewController.h"

#import "Event.h"

#import "EventDetailsHeaderView.h"

@interface EventDetailsViewController ()

#pragma mark - View initialization

- (void)initializeHeaderView;

@end

@implementation EventDetailsViewController

@synthesize event = event_;

@synthesize headerView = headerView_;

#pragma mark - Memory management

- (void)dealloc
{
    [event_ release];
    [headerView_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithEvent:(Event *)event
{
    self = [super initWithNibName:@"EventDetailsViewController" bundle:nil];
    if (self) {
        event_ = [event retain];
        [self setTitle:NSLocalizedString(@"global.details", nil)];
    }

    return self;
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeHeaderView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    return io == UIInterfaceOrientationPortrait;
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

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - View initialization

- (void)initializeHeaderView
{
    Event *event = [self event];
    EventDetailsHeaderView *headerView = [self headerView];
    [headerView configureForEvent:event];
    [[self tableView] setTableHeaderView:headerView];
}

@end
