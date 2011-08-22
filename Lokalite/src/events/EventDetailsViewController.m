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
#import "Location.h"

#import "EventDetailsHeaderView.h"
#import "EventDetailsFooterView.h"
#import "ExpandableTextTableViewCell.h"
#import "DetailViewTableViewCell.h"
#import "LocationTableViewCell.h"
#import "LocationViewController.h"

#import "BusinessDetailsViewController.h"

#import "LokaliteAppDelegate.h"

#import "LokaliteService.h"

#import "SDKAdditions.h"

enum {
    kSectionInfo,
    kSectionLocation
};
static const NSInteger NUM_SECTIONS = kSectionLocation + 1;


enum {
    //kInfoRowPhone,
    //kInfoRowBusinessName,
    kInfoRowEventTime,
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

//
// Controls whether the event description field will only show a couple lines of
// text and expand if necessary. This has been disabled for now as descriptions
// are limited to 140 characters and it's not a problem to show the full length
// of the description. I've left most of the code in place and just set this
// value to false during initialization.
//
@property (nonatomic, assign, getter=isDescriptionExpanded)
    BOOL descriptionExpanded;

@property (nonatomic, retain) LokaliteService *service;

#pragma mark - View initialization

- (void)initializeNavigationItem;
- (void)initializeTableView;
- (void)initializeHeaderView;
- (void)initializeMapView;
- (void)initializeFooterView;

#pragma mark - Table view configuration

+ (NSString *)dequeueReusableCellWithReuseIdentifier:(NSIndexPath *)path;
- (UITableViewCell *)cellInstanceForIndexPath:(NSIndexPath *)path
                              reuseIdentifier:(NSString *)reuseIdentifier;

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath;

- (void)configureHeaderForEvent:(Event *)event;
- (void)configureFooterForEvent:(Event *)event;

#pragma mark - Location

- (void)displayLocationDetailsForEvent:(Event *)event;
- (void)displayBusinessDetails:(Business *)business;

#pragma mark - Updating for event states

- (void)observeChangesForEvent:(Event *)event;
- (void)stopObservingChangesForEvent:(Event *)event;

#pragma mark - Constants

+ (UIFont *)eventDescriptionFont;

@end


@implementation EventDetailsViewController

@synthesize event = event_;

@synthesize headerView = headerView_;
@synthesize locationMapCell = locationMapCell_;
@synthesize footerView = footerView_;
@synthesize trendTableViewCell = trendTableViewCell_;

@synthesize descriptionExpanded = descriptionExpanded_;

@synthesize service = service_;

#pragma mark - Memory management

- (void)dealloc
{
    [self stopObservingChangesForEvent:event_];

    [event_ release];
    [headerView_ release];
    [locationMapCell_ release];
    [footerView_ release];
    [trendTableViewCell_ release];

    [service_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithEvent:(Event *)event
{
    self = [super initWithNibName:@"EventDetailsView" bundle:nil];
    if (self) {
        event_ = [event retain];
        descriptionExpanded_ = YES;
        [self setTitle:NSLocalizedString(@"global.event", nil)];
    }

    return self;
}

#pragma mark - UI events

- (IBAction)presentSharingOptions:(id)sender
{
    [self presentSharingOptionsWithDelegate:self];
}

- (void)mapViewTapped:(UIGestureRecognizer *)recognizer
{
    [self displayLocationDetailsForEvent:[self event]];
}

- (IBAction)toggleTrendStatus:(id)sender
{
    Event *event = [self event];
    NSNumber *eventId = [event identifier];
    BOOL isTrended = [[event trended] boolValue];

    LSResponseHandler handler =
        ^(NSHTTPURLResponse *response, NSDictionary *json, NSError *error) {
            NSString *label = isTrended ? @"Untrend" : @"Trend";
            NSLog(@"%@ status: %d", label, [response statusCode]);
            if (error)
                NSLog(@"%@ error: %@", label, [error detailedDescription]);
        };

    if (isTrended)
        [[self service] untrendEventWithEventId:eventId
                                responseHandler:handler];
    else
        [[self service] trendEventWithEventId:eventId responseHandler:handler];

    [event trendEvent:!isTrended];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];
    [self initializeTableView];
    [self initializeMapView];

    [self observeChangesForEvent:[self event]];
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

    if ([indexPath section] == kSectionInfo) {
        if ([indexPath row] == kInfoRowEventDescription) {
            NSString *info = [[self event] summary];
            BOOL expanded = [self isDescriptionExpanded];
            UIFont *font = [[self class] eventDescriptionFont];
            height = [ExpandableTextTableViewCell cellHeightForText:info
                                                           withFont:font
                                                           expanded:expanded];
        }
    } else if ([indexPath section] == kSectionLocation) {
        if ([indexPath row] == kLocationRowMap)
            height = [LocationTableViewCell cellHeight];
    }

    return height;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@: %@", NSStringFromSelector(_cmd), indexPath);

    if ([indexPath section] == kSectionInfo) {
        /*
        if ([indexPath row] == kInfoRowEventDescription) {
            ExpandableTextTableViewCell *cell = (ExpandableTextTableViewCell *)
                [tableView cellForRowAtIndexPath:indexPath];
            [cell setExpanded:![cell isExpanded]];
            [self setDescriptionExpanded:[cell isExpanded]];
            [tableView beginUpdates];
            [tableView endUpdates];

            [tableView deselectRowAtIndexPath:indexPath animated:YES];
        }
         */
    } else if ([indexPath section] == kSectionLocation) {
        if ([indexPath row] == kLocationRowTitle)
            [self displayBusinessDetails:[[self event] business]];
        else if ([indexPath row] == kLocationRowAddress)
            [self displayLocationDetailsForEvent:[self event]];
    }
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    UIBarButtonItem *shareButtonItem =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                              target:self
                              action:@selector(presentSharingOptions:)];
    [[self navigationItem] setRightBarButtonItem:shareButtonItem];
    [shareButtonItem release], shareButtonItem = nil;
}

- (void)initializeTableView
{
    [self initializeHeaderView];
    [self initializeFooterView];
}

- (void)initializeHeaderView
{
    [self configureHeaderForEvent:[self event]];
    [[self tableView] setTableHeaderView:[self headerView]];
}

- (void)initializeMapView
{
    LocationTableViewCell *cell = [self locationMapCell];
    CLLocation *location = [[self event] locationInstance];
    [cell setLocation:location];

    SEL action = @selector(mapViewTapped:);
    UIGestureRecognizer *gr =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:action];
    [gr setDelegate:self];
    [[cell mapView] addGestureRecognizer:gr];
    [gr release], gr = nil;
}

- (void)initializeFooterView
{
    [self configureFooterForEvent:[self event]];
    [[self tableView] setTableFooterView:[self footerView]];
}

#pragma mark - Table view configuration

+ (NSString *)dequeueReusableCellWithReuseIdentifier:(NSIndexPath *)path
{
    NSString *cellIdentifier = nil;

    if ([path section] == kSectionInfo) {
        /*if ([path row] == kInfoRowBusinessName)
            cellIdentifier = @"InfoRowBusinessName";*/
        if ([path row] == kInfoRowEventTime)
            cellIdentifier = @"InfoRowEventTime";
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
        if ([path row] == kInfoRowEventDescription) {
            ExpandableTextTableViewCell *expandableCell =
                [[[ExpandableTextTableViewCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                  reuseIdentifier:reuseIdentifier] autorelease];
            [expandableCell setExpanded:YES];
            [[expandableCell textLabel]
             setFont:[[self class] eventDescriptionFont]];
            cell = expandableCell;
        } else
            cell =
                [[[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleValue1
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
        if ([indexPath row] == kInfoRowEventTime) {
            [[cell detailTextLabel] setText:
             [[self event] dateStringDescription]];
            [[cell textLabel] setText:NSLocalizedString(@"global.time", nil)];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } /*else if ([indexPath row] == kInfoRowPhone) {
            [[cell textLabel] setText:[[[self event] business] phone]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }*/ /*else if ([indexPath row] == kInfoRowBusinessName) {
            [[cell textLabel] setText:[[[self event] business] name]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }*/ else if ([indexPath row] == kInfoRowEventDescription) {
            [[cell textLabel] setText:[[self event] summary]];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    } else if ([indexPath section] == kSectionLocation) {
        if ([indexPath row] == kLocationRowTitle) {
            [[cell textLabel] setText:[[[self event] business] name]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        } else if ([indexPath row] == kLocationRowAddress) {
            Location *location = [[self event] location];
            [[cell textLabel] setText:[location formattedAddress]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
    }
}

- (void)configureHeaderForEvent:(Event *)event
{
    [[self headerView] configureForEvent:event];
}

- (void)configureFooterForEvent:(Event *)event
{
    //[[self footerView] configureForEvent:event];
    [[self tableView] setTableFooterView:[self footerView]];
}

#pragma mark - Location

- (void)displayLocationDetailsForEvent:(Event *)event
{
    LocationViewController *controller =
        [[LocationViewController alloc] initWithMappableLokaliteObject:event];
    [[self navigationController] pushViewController:controller
                                           animated:YES];
    [controller release], controller = nil;
}

- (void)displayBusinessDetails:(Business *)business
{
    BusinessDetailsViewController *controller =
        [[BusinessDetailsViewController alloc] initWithBusiness:business];
    [[self navigationController] pushViewController:controller
                                           animated:YES];
    [controller release], controller = nil;
}

#pragma mark - Updating for event states

- (void)observeChangesForEvent:(Event *)event
{
    [event addObserver:self
            forKeyPath:@"trended"
               options:NSKeyValueObservingOptionNew |
                       NSKeyValueObservingOptionOld
               context:NULL];
}

- (void)stopObservingChangesForEvent:(Event *)event
{
    [event removeObserver:self forKeyPath:@"trended"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"trended"])
        [self configureHeaderForEvent:[self event]];
}

#pragma mark - UIActionSheetDelegate implementation

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"%@ %d", NSStringFromSelector(_cmd), buttonIndex);
}

#pragma mark - Accessors

- (LocationTableViewCell *)locationMapCell
{
    if (!locationMapCell_)
        locationMapCell_ = [[LocationTableViewCell instanceFromNib] retain];

    return locationMapCell_;
}

- (LokaliteService *)service
{
    if (!service_) {
        NSManagedObjectContext *context = [[self event] managedObjectContext];
        service_ =
            [[LokaliteService lokaliteServiceAuthenticatedIfPossible:YES
                                                           inContext:context]
             retain];
    }

    return service_;
}

#pragma mark - Constants

+ (UIFont *)eventDescriptionFont
{
    return [UIFont systemFontOfSize:18];
}

@end
