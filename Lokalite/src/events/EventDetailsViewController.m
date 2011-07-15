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


enum {
    kSectionLocation
};
static const NSInteger NUM_SECTIONS = 1;

enum {
    kLocationRowTitle,
    kLocationRowMap,
    kLocationRowAddress
};
static const NSInteger NUM_LOCATION_ROWS = kLocationRowAddress + 1;


@interface EventDetailsViewController ()

#pragma mark - View initialization

- (void)initializeHeaderView;

#pragma mark - Table view configuration

+ (NSString *)dequeueReusableCellWithReuseIdentifier:(NSIndexPath *)path;
- (UITableViewCell *)cellInstanceForIndexPath:(NSIndexPath *)path
                              reuseIdentifier:(NSString *)reuseIdentifier;

@end

@implementation EventDetailsViewController

@synthesize event = event_;

@synthesize headerView = headerView_;
@synthesize locationMapCell = locationMapCell_;

#pragma mark - Memory management

- (void)dealloc
{
    [event_ release];
    [headerView_ release];
    [locationMapCell_ release];

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
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger nrows = 0;

    switch (section) {
        case kSectionLocation:
            nrows = NUM_LOCATION_ROWS;
            break;
    }

    return nrows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier =
        [[self class] dequeueReusableCellWithReuseIdentifier:indexPath];
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell)
        cell = [self cellInstanceForIndexPath:indexPath
                              reuseIdentifier:cellIdentifier];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;

    if ([indexPath section] == kSectionLocation) {
        if ([indexPath row] == kLocationRowMap)
            height = 138;
    }

    return height;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), indexPath);
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - View initialization

- (void)initializeHeaderView
{
    Event *event = [self event];
    EventDetailsHeaderView *headerView = [self headerView];
    [headerView configureForEvent:event];
    [[self tableView] setTableHeaderView:headerView];
}

#pragma mark - Table view configuration

+ (NSString *)dequeueReusableCellWithReuseIdentifier:(NSIndexPath *)path
{
    NSString *cellIdentifier = nil;

    if ([path section] == kSectionLocation) {
        if ([path row] == kLocationRowAddress)
            cellIdentifier = @"LocationRowAddressTableViewCell";
        else if ([path row] == kLocationRowMap)
            cellIdentifier = @"LocationRowMapTableViewCell";
        else if ([path row] == kLocationRowTitle)
            cellIdentifier = @"LocationRowTitleTableViewCell";
    }

    return cellIdentifier;
}

- (UITableViewCell *)cellInstanceForIndexPath:(NSIndexPath *)path
                              reuseIdentifier:(NSString *)reuseIdentifier
{
    UITableViewCell *cell = nil;

    if ([path section] == kSectionLocation) {
        if ([path row] == kLocationRowMap)
            cell = [self locationMapCell];
        else
            cell =
                [[[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                  reuseIdentifier:reuseIdentifier] autorelease];
    }

    return cell;
}

@end
