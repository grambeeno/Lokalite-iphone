//
//  TrendingViewController.m
//  Lokalite
//
//  Created by John Debay on 7/29/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TrendingViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"

#import "LokaliteTrendingEventStream.h"

#import "TableViewImageFetcher.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface TrendingViewController ()

@property (nonatomic, retain) TableViewImageFetcher *imageFetcher;

#pragma mark - View initialization

- (void)initializeNavigationItem;

@end


@implementation TrendingViewController

@synthesize imageFetcher = imageFetcher_;

#pragma mark - Memory management

- (void)dealloc
{
    [imageFetcher_ release];
    
    [super dealloc];
}

#pragma mark - UIViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];
}

#pragma mark - LokaliteStreamViewController implementation

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.trending", nil);
}

#pragma mark Configuring the table view

- (void)initializeTableView:(UITableView *)tableView
{
    [super initializeTableView:tableView];

    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setRowHeight:[EventTableViewCell cellHeight]];
}

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView
{
    return [EventTableViewCell defaultReuseIdentifier];
}

- (UITableViewCell *)tableViewCellInstanceForTableView:(UITableView *)tableView
                                       reuseIdentifier:(NSString *)identifier
{
    return [EventTableViewCell instanceFromNib];
}

- (void)configureCell:(EventTableViewCell *)cell forObject:(Event *)event
{
    [cell configureCellForEvent:event];

    UIImage *image = [event image];
    if (!image) {
        NSURL *url = [event fullImageUrl];

        [[self imageFetcher] fetchImageDataAtUrl:url
                                       tableView:[self tableView]
                             dataReceivedHandler:
         ^(NSData *data) {
             [event setImageData:data];
         }
                            tableViewCellHandler:
         ^(UIImage *image, UITableViewCell *tvc, NSIndexPath *path) {
             EventTableViewCell *cell = (EventTableViewCell *) tvc;
             if ([[cell eventId] isEqualToNumber:[event identifier]])
                 [[cell eventImageView] setImage:image];
         }
                                    errorHandler:
         ^(NSError *error) {
             NSLog(@"WARNING: Failed to fetch place image at: %@: %@", url,
                   error);
         }];
    }

    [[cell eventImageView] setImage:image];
}

- (void)displayDetailsForObject:(Event *)event
{
    EventDetailsViewController *controller =
        [[EventDetailsViewController alloc] initWithEvent:event];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

#pragma mark Working with the local data store

- (NSString *)lokaliteObjectEntityName
{
    return @"Event";
}

- (NSPredicate *)dataControllerPredicate
{
    NSManagedObjectContext *context = [self context];
    NSDate *date =
        [[LokaliteApplicationState currentState:context] dataFreshnessDate];
    LokaliteDownloadSource *source = [[self lokaliteStream] downloadSource];
    NSString *sourceName = [source name];

    return [NSPredicate predicateForDownloadSourceName:sourceName
                                       lastUpdatedDate:date];
}

- (NSArray *)dataControllerSortDescriptors
{
    return [Event defaultTableViewSortDescriptors];
}

- (LokaliteStream *)lokaliteStreamInstance
{
    return [LokaliteTrendingEventStream streamWithContext:[self context]];
}

#pragma mark Fetching data from the network

- (void)processObjectFetchError:(NSError *)error
                     pageNumber:(NSInteger)pageNumber
{
    NSLog(@"%@: processing fetch error for page %d: %@",
          NSStringFromClass([self class]), pageNumber, error);
    NSString *title = NSLocalizedString(@"featured.fetch.failed", nil);
    NSString *message = [error localizedDescription];
    NSString *dismiss = NSLocalizedString(@"global.dismiss", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:dismiss
                                          otherButtonTitles:nil];
    [alert show];
    [alert release], alert = nil;
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setRightBarButtonItem:
     [self toggleMapViewButtonItem]];
}

#pragma mark - Accessors

- (TableViewImageFetcher *)imageFetcher
{
    if (!imageFetcher_)
        imageFetcher_ = [[TableViewImageFetcher alloc] init];
    
    return imageFetcher_;
}

@end
