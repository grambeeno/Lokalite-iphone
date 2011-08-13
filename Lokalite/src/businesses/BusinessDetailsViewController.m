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

#import "Event.h"
#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"

#import "DataFetcher.h"

#import "SDKAdditions.h"


enum {
    kSectionInfo,
    kSectionUpcomingEvents
};
static const NSUInteger NUM_SECTIONS = kSectionUpcomingEvents + 1;

enum {
    kInfoRowAddress,
    kInfoRowPhoneNumber,
    kInfoRowSummary
};
static const NSUInteger NUM_INFO_ROWS = kInfoRowSummary + 1;

enum {
    kUpcomingRow
};


@interface BusinessDetailsViewController ()

@property (nonatomic, copy) NSArray *events;

#pragma mark - View initialization

- (void)initializeHeaderView;

#pragma mark - View configuration

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path;

#pragma mark - Fetching business images

- (BOOL)fetchBusinessImageIfNecessary;
- (void)fetchImageForEvent:(Event *)event;

@end

@implementation BusinessDetailsViewController

@synthesize business = business_;
@synthesize events = events_;

@synthesize headerView = headerView_;

#pragma mark - Memory management

- (void)dealloc
{
    [headerView_ release];

    [business_ release];
    [events_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithBusiness:(Business *)business
{
    self = [super initWithNibName:@"BusinessDetailsView" bundle:nil];
    if (self) {
        business_ = [business retain];
        [self setTitle:NSLocalizedString(@"global.business", nil)];
    }

    return self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setEvents:[[[self business] events] allObjects]];

    [self initializeHeaderView];
    [self fetchBusinessImageIfNecessary];
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

    if (section == kSectionInfo)
        nrows = NUM_INFO_ROWS;
    else if (section == kSectionUpcomingEvents)
        nrows = [[self events] count];

    return nrows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;

    if ([indexPath section] == kSectionInfo) {
        static NSString *CellIdentifier = @"Cell";

        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell =
                [[[UITableViewCell alloc]
                  initWithStyle:UITableViewCellStyleDefault
                  reuseIdentifier:CellIdentifier] autorelease];
        }
    } else if ([indexPath section] == kSectionUpcomingEvents) {
        static NSString *CellIdentifier = nil;
        if (!CellIdentifier)
            CellIdentifier = [[EventTableViewCell defaultReuseIdentifier] copy];

        cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [EventTableViewCell instanceFromNib];
    }

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 44;
    if ([indexPath section] == kSectionUpcomingEvents)
        height = [EventTableViewCell cellHeight];

    return height;
}

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)path
{
    if ([path section] == kSectionInfo) {
        NSURL *url = nil;

        if ([path row] == kInfoRowAddress)
            url = [[self business] addressUrl];
        else if ([path row] == kInfoRowPhoneNumber)
            url = [[self business] phoneUrl];

        UIApplication *app = [UIApplication sharedApplication];
        if (url && [app canOpenURL:url])
            [app openURL:url];
    } else if ([path section] == kSectionUpcomingEvents) {
        Event *event = [[self events] objectAtIndex:[path row]];
        EventDetailsViewController *controller =
            [[EventDetailsViewController alloc] initWithEvent:event];
        [[self navigationController] pushViewController:controller
                                               animated:YES];
        [controller release], controller = nil;
    }
}

#pragma mark - View initialization

- (void)initializeHeaderView
{
    [[self headerView] configureForBusiness:[self business]];
    [[self tableView] setTableHeaderView:[self headerView]];
}

#pragma mark - View configuration

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path
{
    if ([path section] == kSectionInfo) {
        UIApplication *app = [UIApplication sharedApplication];

        if ([path row] == kInfoRowAddress) {
            [[cell textLabel] setText:[[[self business] location] formattedAddress]];

            if ([app canOpenURL:[[self business] addressUrl]]) {
                [cell setAccessoryType:
                 UITableViewCellAccessoryDisclosureIndicator];
                [cell setSelectionStyle:
                 UITableViewCellSelectionStyleBlue];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        } else if ([path row] == kInfoRowPhoneNumber) {
            [[cell textLabel] setText:[[self business] phone]];

            if ([app canOpenURL:[[self business] phoneUrl]]) {
                [cell setAccessoryType:
                 UITableViewCellAccessoryDisclosureIndicator];
                [cell setSelectionStyle:
                 UITableViewCellSelectionStyleBlue];
            } else {
                [cell setAccessoryType:UITableViewCellAccessoryNone];
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            }
        } else if ([path row] == kInfoRowSummary) {
            [[cell textLabel] setText:[[self business] summary]];

            [cell setAccessoryType:UITableViewCellAccessoryNone];
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
        }
    } else if ([path section] == kSectionUpcomingEvents) {
        Event *event = [[self events] objectAtIndex:[path row]];
        EventTableViewCell *eventCell = (EventTableViewCell *) cell;
        [eventCell configureCellForEvent:event currentLocation:nil];

        NSData *imageData = [event imageData];
        if (imageData)
            [[eventCell eventImageView] setImage:
             [UIImage imageWithData:imageData]];
        else {
            [[eventCell eventImageView] setImage:nil];
            [self fetchImageForEvent:event];
        }
    }
}

#pragma mark - Fetching data

- (BOOL)fetchBusinessImageIfNecessary
{
    Business *business = [self business];
    BusinessDetailsHeaderView *headerView = [self headerView];
    NSData *imageData = [business imageData];

    BOOL fetched = NO;
    if (!imageData) {
        NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
        NSURL *url = [baseUrl URLByAppendingPathComponent:[business imageUrl]];

        [DataFetcher fetchDataAtUrl:url responseHandler:
         ^(NSData *data, NSError *error) {
             if (error) {
                 NSLog(@"Failed to download image for business at URL: %@: %@",
                       url, [error detailedDescription]);
             } else {
                 [business setImageData:data];
                 [headerView configureForBusiness:business];
             }
        }];

        fetched = YES;
    }

    return fetched;
}

- (void)fetchImageForEvent:(Event *)event
{
    [[UIApplication sharedApplication] networkActivityIsStarting];

    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    NSString *urlPath = [event imageUrl];
    NSURL *url = [baseUrl URLByAppendingPathComponent:urlPath];

    UITableView *tableView = [self tableView];
    NSArray *events = [self events];
    [DataFetcher fetchDataAtUrl:url responseHandler:
     ^(NSData *data, NSError *error) {
         [[UIApplication sharedApplication] networkActivityDidFinish];

         if (data) {
             __block UIImage *image = nil;
             NSArray *visibleCells = [tableView visibleCells];
             [visibleCells enumerateObjectsUsingBlock:
              ^(EventTableViewCell *cell, NSUInteger idx, BOOL *stop) {
                  NSIndexPath *path = [tableView indexPathForCell:cell];
                  Event *e = [events objectAtIndex:[path row]];
                  if ([[e imageUrl] isEqualToString:urlPath]) {
                      if (!image)
                          image = [UIImage imageWithData:data];
                      [[cell eventImageView] setImage:image];
                      [e setImageData:data];
                  }
             }];
         } else
             NSLog(@"WARNING: Failed to download image data for event: %@: %@",
                   [event identifier], [error detailedDescription]);
    }];
}

@end
