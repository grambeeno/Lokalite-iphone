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
#import "LocationTableViewCell.h"

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
    
    kInfoRowHours,
    //kInfoRowPhone,
    //kInfoRowBusinessName,
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

@property (nonatomic, retain) LokaliteService *service;

#pragma mark - View initialization

- (void)initializeNavigationItem;
- (void)initializeHeaderView;
- (void)initializeMapView;
- (void)initializeFooterView;

#pragma mark - Table view configuration

+ (NSString *)dequeueReusableCellWithReuseIdentifier:(NSIndexPath *)path;
- (UITableViewCell *)cellInstanceForIndexPath:(NSIndexPath *)path
                              reuseIdentifier:(NSString *)reuseIdentifier;

- (void)configureCell:(UITableViewCell *)cell
          atIndexPath:(NSIndexPath *)indexPath;

- (void)configureFooterForEvent:(Event *)event;

#pragma mark - Updating for event states

- (void)observeChangesForEvent:(Event *)event;
- (void)stopObservingChangesForEvent:(Event *)event;

@end


@implementation EventDetailsViewController

@synthesize event = event_;

@synthesize headerView = headerView_;
@synthesize locationMapCell = locationMapCell_;
@synthesize footerView = footerView_;

@synthesize service = service_;

#pragma mark - Memory management

- (void)dealloc
{
    [self stopObservingChangesForEvent:event_];

    [event_ release];
    [headerView_ release];
    [locationMapCell_ release];
    [footerView_ release];

    [service_ release];

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

#pragma mark - Button actions

- (IBAction)presentSharingOptions:(id)sender
{
    NSString *title = nil;
    NSString *cancelButtonTitle = NSLocalizedString(@"global.cancel", nil);
    NSString *sendEmailButtonTitle =
        NSLocalizedString(@"global.send-email", nil);
    NSString *sendTextMessageButtonTitle =
        NSLocalizedString(@"global.send-text-message", nil);
    NSString *postToFacebookButtonTitle =
        NSLocalizedString(@"global.post-to-facebook", nil);
    NSString *postToTwitterButtonTitle =
        NSLocalizedString(@"global.post-to-twitter", nil);

    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:title
                                    delegate:self
                           cancelButtonTitle:cancelButtonTitle
                      destructiveButtonTitle:nil
                           otherButtonTitles:sendEmailButtonTitle,
                                             sendTextMessageButtonTitle,
                                             postToFacebookButtonTitle,
                                             postToTwitterButtonTitle, nil];

    LokaliteAppDelegate *appDelegate =
        (LokaliteAppDelegate *) [[UIApplication sharedApplication] delegate];
    UITabBar *tabBar = [[appDelegate tabBarController] tabBar];
    [sheet showFromTabBar:tabBar];
    [sheet release], sheet = nil;
}

- (IBAction)toggleTrendStatus:(id)sender
{
    Event *event = [self event];
    NSNumber *eventId = [event identifier];
    BOOL isTrended = [[ event trended] boolValue];

    LSResponseHandler handler =
        ^(NSHTTPURLResponse *response, NSDictionary *json, NSError *error) {
            NSInteger statusCode = [response statusCode];
            if (statusCode == 200) {
                json = [json objectForKey:@"data"];
                NSManagedObjectContext *context = [event managedObjectContext];
                [Event createOrUpdateEventFromJsonData:json
                                        downloadSource:nil
                                             inContext:context];
            } else {
                if (!error)
                    error = [NSError errorForHTTPStatusCode:statusCode];
                NSLog(@"Failed: %@", error);
            }
        };

    if (isTrended)
        [[self service] untrendEventWithEventId:eventId
                                responseHandler:handler];
    else
        [[self service] trendEventWithEventId:eventId responseHandler:handler];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];
    [self initializeHeaderView];
    [self initializeMapView];
    [self initializeFooterView];

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
        /*
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
         */
    }

    if (deselect)
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    CLLocation *location = [[self event] locationInstance];
    [cell setLocation:location];
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
            cellIdentifier = @"InfoRowBusinessName";
        else*/ if ([path row] == kInfoRowEventDescription)
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
        if ([indexPath row] == kInfoRowHours) {
            [[cell detailTextLabel] setText:
             [[self event] dateStringDescription]];
            [[cell textLabel] setText:NSLocalizedString(@"global.hours", nil)];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
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
             //setText:NSLocalizedString(@"global.location", nil)];
            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        } else if ([indexPath row] == kLocationRowAddress) {
            Location *location = [[self event] location];
            [[cell textLabel] setText:[location formattedAddress]];
            [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
            [cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
        }
    }
}

- (void)configureFooterForEvent:(Event *)event
{
    [[self footerView] configureForEvent:event];
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
        [self configureFooterForEvent:[self event]];
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

@end
