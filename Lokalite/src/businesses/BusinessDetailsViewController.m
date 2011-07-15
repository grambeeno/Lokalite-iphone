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

#import "DataFetcher.h"

#import "SDKAdditions.h"


enum {
    kSectionInfo
};
static const NSUInteger NUM_SECTIONS = kSectionInfo + 1;

enum {
    kInfoRowAddress,
    kInfoRowPhoneNumber,
    kInfoRowSummary
};
static const NSUInteger NUM_INFO_ROWS = kInfoRowSummary + 1;


@interface BusinessDetailsViewController ()

#pragma mark - View initialization

- (void)initializeHeaderView;

#pragma mark - View configuration

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)path;

#pragma mark - Fetching business images

- (BOOL)fetchBusinessImageIfNecessary;

@end

@implementation BusinessDetailsViewController

@synthesize business = business_;

@synthesize headerView = headerView_;

#pragma mark - Memory management

- (void)dealloc
{
    [headerView_ release];

    [business_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithBusiness:(Business *)business
{
    self = [super initWithNibName:@"BusinessDetailsView" bundle:nil];
    if (self) {
        business_ = [business retain];
        [self setTitle:NSLocalizedString(@"global.details", nil)];
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

    return nrows;
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

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)path
{
    [tableView deselectRowAtIndexPath:path animated:YES];

    if ([path section] == kSectionInfo) {
        NSURL *url = nil;

        if ([path row] == kInfoRowAddress)
            url = [[self business] addressUrl];
        else if ([path row] == kInfoRowPhoneNumber)
            url = [[self business] phoneUrl];

        UIApplication *app = [UIApplication sharedApplication];
        if (url && [app canOpenURL:url])
            [app openURL:url];
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
        if ([path row] == kInfoRowAddress) {
            [[cell textLabel] setText:[[self business] address]];

            UIApplication *app = [UIApplication sharedApplication];
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

            UIApplication *app = [UIApplication sharedApplication];
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
    }
}

#pragma mark - Fetching business images

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

@end
