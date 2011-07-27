//
//  EventDetailsViewController.m
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventDetailsViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"
#import "Business.h"
#import "Venue.h"
#import "Location.h"

#import "EventDetailsHeaderView.h"
#import "EventDetailsFooterView.h"
#import "LocationTableViewCell.h"

#import "BusinessDetailsViewController.h"

#import "SDKAdditions.h"

enum {
    kSectionInfo,
    kSectionLocation
};
static const NSInteger NUM_SECTIONS = kSectionLocation + 1;


enum {
    kInfoRowBusinessName,
    kInfoRowEventDescription
};
static const NSInteger NUM_INFO_ROWS = kInfoRowEventDescription + 1;

enum {
    kLocationRowTitle,
    kLocationRowMap,
    kLocationRowAddress
};
static const NSInteger NUM_LOCATION_ROWS = kLocationRowAddress + 1;


@interface EventDetailsViewController ()

#pragma mark - View initialization

- (void)initializeHeaderView;
- (void)initializeMapView;
- (void)initializeFooterView;

#pragma mark - Table view configuration

+ (NSString *)dequeueReusableCellWithReuseIdentifier:(NSIndexPath *)path;
- (UITableViewCell *)cellInstanceForIndexPath:(NSIndexPath *)path
                              reuseIdentifier:(NSString *)reuseIdentifier;

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath;

@end


@implementation EventDetailsViewController

@synthesize event = event_;

@synthesize headerView = headerView_;
@synthesize locationMapCell = locationMapCell_;
@synthesize footerView = footerView_;

#pragma mark - Memory management

- (void)dealloc
{
    [event_ release];
    [headerView_ release];
    [locationMapCell_ release];
    [footerView_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithEvent:(Event *)event
{
    self = [super initWithNibName:@"EventDetailsView" bundle:nil];
    if (self) {
        event_ = [event retain];
        [self setTitle:NSLocalizedString(@"global.event", nil)];
    }

    return self;
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeHeaderView];
    [self initializeMapView];
    [self initializeFooterView];
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
        case kSectionInfo:
            nrows = NUM_INFO_ROWS;
            break;
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

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;

    if ([indexPath section] == kSectionLocation) {
        if ([indexPath row] == kLocationRowMap)
            height = 120;
    }

    return height;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), indexPath);

    BOOL deselect = YES;
    if ([indexPath section] == kSectionInfo) {
        if ([indexPath row] == kInfoRowBusinessName) {
            deselect = NO;

            Business *business = [[self event] business];
            BusinessDetailsViewController *controller =
                [[BusinessDetailsViewController alloc]
                 initWithBusiness:business];
            [[self navigationController] pushViewController:controller
                                                   animated:YES];
            [controller release], controller = nil;
        }
    }

    if (deselect)
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

- (void)initializeMapView
{
    LocationTableViewCell *cell = [self locationMapCell];
    CLLocation *location = [[self event] location];
    [cell setLocation:location];
}

- (void)initializeFooterView
{
    Event *event = [self event];
    EventDetailsFooterView *footerView = [self footerView];
    [footerView configureForEvent:event];
    [[self tableView] setTableFooterView:footerView];
}

#pragma mark - Table view configuration

+ (NSString *)dequeueReusableCellWithReuseIdentifier:(NSIndexPath *)path
{
    NSString *cellIdentifier = nil;

    if ([path section] == kSectionInfo) {
        if ([path row] == kInfoRowBusinessName)
            cellIdentifier = @"InfoRowBusinessName";
        else if ([path row] == kInfoRowEventDescription)
            cellIdentifier = @"InfoRowEventDescription";
    } else if ([path section] == kSectionLocation) {
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

    if ([path section] == kSectionInfo) {
        cell =
            [[[UITableViewCell alloc]
              initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:reuseIdentifier] autorelease];
    } else if ([path section] == kSectionLocation) {
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

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == kSectionInfo) {
        if ([indexPath row] == kInfoRowBusinessName) {
            [[cell textLabel] setText:[[[self event] business] name]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        } else if ([indexPath row] == kInfoRowEventDescription) {
            [[cell textLabel] setText:[[self event] summary]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    } else if ([indexPath section] == kSectionLocation) {
        if ([indexPath row] == kLocationRowTitle) {
            [[cell textLabel]
             setText:NSLocalizedString(@"global.location", nil)];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } else if ([indexPath row] == kLocationRowAddress) {
            Location *location = [[[self event] venue] location];
            [[cell textLabel] setText:[location formattedAddress]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
    }
}

#pragma mark - Accessors

- (LocationTableViewCell *)locationMapCell
{
    if (!locationMapCell_)
        locationMapCell_ = [[LocationTableViewCell instanceFromNib] retain];

    return locationMapCell_;
}

@end
