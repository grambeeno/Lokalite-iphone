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

#import "PlaceEventStreamViewController.h"

#import "DataFetcher.h"

#import "SharingController.h"

#import "SDKAdditions.h"


enum {
    kSectionMore,
    kSectionInfo,
    kSectionLocation,
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

#pragma mark - Showing business data

- (void)displayLocationDetailsForBusiness:(Business *)business;
- (void)displayMoreEventsForBusiness:(Business *)business;

#pragma mark - Fetching business images

- (BOOL)fetchBusinessImageIfNecessary;

#pragma mark - Updating for business states

- (void)observeChangesForBusiness:(Business *)business;
- (void)stopObservingChangesForBusiness:(Business *)business;

#pragma mark - Sharing

@property (nonatomic, retain) SharingController *sharingController;

#pragma mark - Constants

+ (UIFont *)defaultCellTextLabelFont;
+ (UIFont *)descriptionCellTextLabelFont;

@end


@implementation BusinessDetailsViewController

@synthesize business = business_;

@synthesize locationMapCell = locationMapCell_;
@synthesize headerView = headerView_;
@synthesize sharingController = sharingController_;

#pragma mark - Memory management

- (void)dealloc
{
    [self stopObservingChangesForBusiness:[self business]];

    [headerView_ release];
    [business_ release];
    [locationMapCell_ release];
    [sharingController_ release];

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
    [[self sharingController] share];
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

    [self observeChangesForBusiness:[self business]];
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

- (NSString *)tableView:(UITableView *)tableView
    titleForHeaderInSection:(NSInteger)section
{
    section = [self effectiveSectionForSection:section];

    NSString *title = nil;
    if (section == kSectionDescription) {
        NSString *format =
            NSLocalizedString(@"business-details.about.formatstring", nil);
        title = [NSString stringWithFormat:format, [[self business] name]];
    }

    return title;
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
            UIFont *font = [[self class] descriptionCellTextLabelFont];
            CGSize maxSize = CGSizeMake(280, FLT_MAX);
            NSString *summary = [[self business] summary];
            CGSize size = [summary sizeWithFont:font
                              constrainedToSize:maxSize
                                  lineBreakMode:UILineBreakModeWordWrap];

            // provide sufficient vertical padding
            height = size.height + 16;
        }
    }

    return height;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)path
{
    path = [self effectiveIndexPathForIndexPath:path];

    if ([path section] == kSectionInfo) {
        NSURL *url = nil;
        if ([path row] == kInfoRowPhoneNumber)
            url = [[self business] phoneUrl];
        else if ([path row] == kInfoRowUrl)
            url = [NSURL URLWithString:[[self business] url]];

        BOOL opened = [[UIApplication sharedApplication] openURL:url];
        if (!opened)
            // malformatted phone number or URL received from the server
            NSLog(@"WARNING: Failed to open URL: '%@'", url);

        [tableView deselectRowAtIndexPath:path animated:YES];
    } else if ([path section] == kSectionLocation) {
        if ([path row] == kLocationRowAddress)
            [self displayLocationDetailsForBusiness:[self business]];
    } else if ([path section] == kSectionMore) {
        if ([path row] == kMoreRowMoreEvents)
            [self displayMoreEventsForBusiness:[self business]];
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

    UIFont *textLabelFont = [[self class] defaultCellTextLabelFont];
    NSInteger numberOfLines = 1;
    UITableViewCellAccessoryType accessoryType = UITableViewCellAccessoryNone;
    UITableViewCellSelectionStyle selectionStyle =
        UITableViewCellSelectionStyleNone;

    if ([path section] == kSectionInfo) {
        UIApplication *app = [UIApplication sharedApplication];

        if ([path row] == kInfoRowPhoneNumber) {
            [[cell textLabel] setText:[business phone]];

            accessoryType = UITableViewCellAccessoryNone;
            if ([app canOpenURL:[business phoneUrl]])
                selectionStyle = UITableViewCellSelectionStyleBlue;
            else
                selectionStyle = UITableViewCellSelectionStyleNone;
        } else if ([path row] == kInfoRowUrl) {
            [[cell textLabel] setText:[business url]];

            accessoryType = UITableViewCellAccessoryNone;
            selectionStyle = UITableViewCellSelectionStyleBlue;
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
             textLabelFont = [[self class] descriptionCellTextLabelFont];
        }
    }

    [cell setAccessoryType:accessoryType];
    [cell setSelectionStyle:selectionStyle];
    [[cell textLabel] setNumberOfLines:numberOfLines];
    [[cell textLabel] setFont:textLabelFont];
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
    NSInteger row = [indexPath row];
    if (section == kSectionInfo) {
        if (![[self business] phone])
            ++row;
    }

    return [NSIndexPath indexPathForRow:row inSection:section];
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

#pragma mark - Showing business data

- (void)displayLocationDetailsForBusiness:(Business *)business
{
    LocationViewController *controller =
        [[LocationViewController alloc]
         initWithMappableLokaliteObject:[self business]];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

- (void)displayMoreEventsForBusiness:(Business *)business
{
    PlaceEventStreamViewController *controller =
        [[PlaceEventStreamViewController alloc] initWithPlace:[self business]];
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

#pragma mark - Updating for business states

- (void)observeChangesForBusiness:(Business *)business
{
    [business addObserver:self
               forKeyPath:@"mediumImageData"
                  options:NSKeyValueObservingOptionNew |
                          NSKeyValueObservingOptionOld
                  context:NULL];
}

- (void)stopObservingChangesForBusiness:(Business *)business
{
    [business removeObserver:self forKeyPath:@"mediumImageData"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqualToString:@"mediumImageData"])
        [[self headerView] configureForBusiness:[self business]];
}

#pragma mark - Accessors

- (LocationTableViewCell *)locationMapCell
{
    if (!locationMapCell_)
        locationMapCell_ = [[LocationTableViewCell instanceFromNib] retain];

    return locationMapCell_;
}

- (SharingController *)sharingController
{
    if (!sharingController_) {
        Business *business = [self business];
        NSManagedObjectContext *context = [business managedObjectContext];
        sharingController_ =
            [[SharingController alloc] initWithShareableObject:business
                                                       context:context];
    }

    return sharingController_;
}

#pragma mark - Constants

+ (UIFont *)defaultCellTextLabelFont
{
    return [UIFont boldSystemFontOfSize:18];
}

+ (UIFont *)descriptionCellTextLabelFont
{
    return [UIFont systemFontOfSize:16];
}

@end
