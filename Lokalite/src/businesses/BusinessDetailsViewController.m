//
//  BusinessDetailsViewController.m
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "BusinessDetailsViewController.h"

#import "BusinessDetailsHeaderView.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"

#import "Location.h"
#import "LocationViewController.h"
#import "LocationTableViewCell.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "DataFetcher.h"

#import "SDKAdditions.h"


enum {
    kSectionInfo,
    kSectionLocation,
    kSectionMore,
    kSectionDescription
};
static const NSUInteger NUM_SECTIONS = kSectionDescription + 1;

enum {
    kInfoRowPhoneNumber,
    kInfoRowUrl
};
static const NSUInteger NUM_INFO_ROWS = kInfoRowUrl + 1;

enum {
    kLocationRowTitle,
    kLocationRowMap,
    kLocationRowAddress
};
static const NSUInteger NUM_LOCATION_ROWS = kLocationRowAddress + 1;

enum {
    kMoreRowMoreEvents
};
static const NSUInteger NUM_MORE_ROWS = kMoreRowMoreEvents + 1;

enum {
    kDescriptionRowDescription
};
static const NSUInteger NUM_DESCRIPTION_ROWS = kDescriptionRowDescription + 1;


@interface BusinessDetailsViewController ()

@property (nonatomic, retain) LocationTableViewCell *locationMapCell;

#pragma mark - View initialization

- (void)initializeNavigationItem;
- (void)initializeHeaderView;
- (void)initializeMapView;

#pragma mark - View configuration

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path;

#pragma mark - Table view management

- (NSInteger)effectiveSectionForSection:(NSInteger)section;
- (NSIndexPath *)effectiveIndexPathForIndexPath:(NSIndexPath *)indexPath;

#pragma mark - Business validation

- (BOOL)businessHasInfo;
- (NSInteger)numberOfBusinessInfoFields;

#pragma mark - Business locations

- (void)displayLocationDetailsForBusiness:(Business *)business;

#pragma mark - Fetching business images

- (BOOL)fetchBusinessImageIfNecessary;

@end


@implementation BusinessDetailsViewController

@synthesize business = business_;

@synthesize locationMapCell = locationMapCell_;
@synthesize headerView = headerView_;

#pragma mark - Memory management

- (void)dealloc
{
    [headerView_ release];

    [business_ release];

    [locationMapCell_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithBusiness:(Business *)business
{
    self = [super initWithNibName:@"BusinessDetailsView" bundle:nil];
    if (self) {
        business_ = [business retain];
        [self setTitle:NSLocalizedString(@"global.place", nil)];
    }

    return self;
}

#pragma mark - UI events

- (void)presentSharingOptions:(id)sender
{
    [self presentSharingOptionsWithDelegate:self];
}

- (void)mapViewTapped:(UIGestureRecognizer *)recognizer
{
    [self displayLocationDetailsForBusiness:[self business]];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];
    [self initializeHeaderView];
    [self initializeMapView];
    [self fetchBusinessImageIfNecessary];
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [self businessHasInfo] ? NUM_SECTIONS : NUM_SECTIONS - 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    section = [self effectiveSectionForSection:section];
    NSInteger nrows = 0;

    if (section == kSectionInfo)
        nrows = [self numberOfBusinessInfoFields];
    else if (section == kSectionLocation)
        nrows = NUM_LOCATION_ROWS;
    else if (section == kSectionMore)
        nrows = NUM_MORE_ROWS;
    else if (section == kSectionDescription)
        nrows = NUM_DESCRIPTION_ROWS;

    return nrows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexPath = [self effectiveIndexPathForIndexPath:indexPath];
    UITableViewCell *cell = nil;
    static NSString *CellIdentifier = @"DefaultTableViewCell";

    if ([indexPath section] == kSectionInfo ||
        [indexPath section] == kSectionMore ||
        [indexPath section] == kSectionDescription)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell =
                [[[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                  reuseIdentifier:CellIdentifier] autorelease];
        }
    } else if ([indexPath section] == kSectionLocation) {
        NSString *identifier =
            [indexPath row] == kLocationRowMap ?
            [LocationTableViewCell defaultReuseIdentifier] : CellIdentifier;

        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (cell == nil) {
            if ([indexPath row] == kLocationRowMap)
                cell = [self locationMapCell];
            else
                cell =
                    [[[UITableViewCell alloc]
                      initWithStyle:UITableViewCellStyleDefault
                      reuseIdentifier:identifier] autorelease];
        }
    }

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    indexPath = [self effectiveIndexPathForIndexPath:indexPath];

    CGFloat height = 44;
    if ([indexPath section] == kSectionLocation) {
        if ([indexPath row] == kLocationRowMap)
            height = [LocationTableViewCell cellHeight];
    } else if ([indexPath section] == kSectionDescription) {
        if ([indexPath row] == kDescriptionRowDescription) {
            // HACK: hardcoding to the standard table view cell font
            UIFont *font = [UIFont boldSystemFontOfSize:18];
            CGSize maxSize = CGSizeMake(280, FLT_MAX);
            NSString *summary = [[self business] summary];
            CGSize size = [summary sizeWithFont:font
                              constrainedToSize:maxSize
                                  lineBreakMode:UILineBreakModeWordWrap];

            // 20 points provides sufficient vertical padding
            height = size.height + 20;
        }
    }

    return height;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)path
{
    path = [self effectiveIndexPathForIndexPath:path];

    if ([path section] == kSectionLocation) {
        if ([path row] == kLocationRowAddress)
            [self displayLocationDetailsForBusiness:[self business]];
    }
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    UIBarButtonItem *actionButtonItem =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                              target:self
                              action:@selector(presentSharingOptions:)];
    [[self navigationItem] setRightBarButtonItem:actionButtonItem];
    [actionButtonItem release], actionButtonItem = nil;
}

- (void)initializeHeaderView
{
    [[self headerView] configureForBusiness:[self business]];
    [[self tableView] setTableHeaderView:[self headerView]];
}

- (void)initializeMapView
{
    LocationTableViewCell *cell = [self locationMapCell];
    CLLocation *location = [[self business] locationInstance];
    [cell setLocation:location];

    SEL action = @selector(mapViewTapped:);
    UIGestureRecognizer *gr =
        [[UITapGestureRecognizer alloc] initWithTarget:self
                                                action:action];
    [gr setDelegate:self];
    [[cell mapView] addGestureRecognizer:gr];
    [gr release], gr = nil;
}

#pragma mark - View configuration

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path
{
    Business *business = [self business];

    NSInteger numberOfLines = 1;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
    UITableViewCellSelectionStyle selectionStyle =
        UITableViewCellSelectionStyleNone;

    if ([path section] == kSectionInfo) {
        UIApplication *app = [UIApplication sharedApplication];

        if ([path row] == kInfoRowPhoneNumber) {
            [[cell textLabel] setText:[business phone]];

            if ([app canOpenURL:[business phoneUrl]]) {
                accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                selectionStyle = UITableViewCellSelectionStyleBlue;
            } else {
                accessoryType = UITableViewCellAccessoryNone;
                selectionStyle = UITableViewCellSelectionStyleNone;
            }
        } else if ([path row] == kInfoRowUrl) {
            [[cell textLabel] setText:[business url]];

            accessoryType = UITableViewCellAccessoryNone;
            selectionStyle = UITableViewCellSelectionStyleNone;
        }
    } else if ([path section] == kSectionLocation) {
        if ([path row] == kLocationRowTitle) {
            [[cell textLabel]
             setText:NSLocalizedString(@"global.location", nil)];
            accessoryType = UITableViewCellAccessoryNone;
            selectionStyle = UITableViewCellSelectionStyleNone;
        } else if ([path row] == kLocationRowAddress) {
            [[cell textLabel] setText:[[business location] formattedAddress]];
            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    } else if ([path section] == kSectionMore) {
        if ([path row] == kMoreRowMoreEvents) {
            NSString *format =
                NSLocalizedString(@"business-details.more-events.formatstring",
                                  nil);
            NSString *text =
                [NSString stringWithFormat:format, [business name]];
            [[cell textLabel] setText:text];
            accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            selectionStyle = UITableViewCellSelectionStyleBlue;
        }
    } else if ([path section] == kSectionDescription) {
         if ([path row] == kDescriptionRowDescription) {
            [[cell textLabel] setText:[business summary]];
            accessoryType = UITableViewCellAccessoryNone;
            selectionStyle = UITableViewCellSelectionStyleNone;
            numberOfLines = 0;
        }
    }

    [cell setAccessoryType:accessoryType];
    [cell setSelectionStyle:selectionStyle];
    [[cell textLabel] setNumberOfLines:numberOfLines];
}

#pragma mark - Table view management

- (NSInteger)effectiveSectionForSection:(NSInteger)section
{
    NSInteger effectiveSection = section;

    if (![self businessHasInfo])
        effectiveSection = section + 1;

    return effectiveSection;
}

- (NSIndexPath *)effectiveIndexPathForIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = [self effectiveSectionForSection:[indexPath section]];
    return [NSIndexPath indexPathForRow:[indexPath row] inSection:section];
}

#pragma mark - Business validation

- (BOOL)businessHasInfo
{
    return [self numberOfBusinessInfoFields] > 0;
}

- (NSInteger)numberOfBusinessInfoFields
{
    Business *business = [self business];
    NSInteger nrows = 0;

    if ([business phone])
        ++nrows;
    if ([business url])
        ++nrows;

    return nrows;
}

#pragma mark - Business locations

- (void)displayLocationDetailsForBusiness:(Business *)business
{
    LocationViewController *controller =
        [[LocationViewController alloc]
         initWithMappableLokaliteObject:[self business]];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

#pragma mark - Fetching data

- (BOOL)fetchBusinessImageIfNecessary
{
    Business *business = [self business];
    BusinessDetailsHeaderView *headerView = [self headerView];
    UIImage *image = [business standardImage];

    BOOL fetched = NO;
    if (!image) {
        NSURL *url = [NSURL URLWithString:[business standardImageUrl]];

        [DataFetcher fetchDataAtUrl:url responseHandler:
         ^(NSData *data, NSError *error) {
             if (error) {
                 NSLog(@"Failed to download image for business at URL: %@: %@",
                       url, [error detailedDescription]);
             } else {
                 [business setStandardImageData:data];
                 [headerView configureForBusiness:business];
             }
        }];

        fetched = YES;
    }

    return fetched;
}

#pragma mark - Accessors

- (LocationTableViewCell *)locationMapCell
{
    if (!locationMapCell_)
        locationMapCell_ = [[LocationTableViewCell instanceFromNib] retain];

    return locationMapCell_;
}

@end
