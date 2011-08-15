//
//  AllEventsViewController.m
//  Lokalite
//
//  Created by John Debay on 8/3/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "AllEventsViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "LokaliteDownloadSource.h"

#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"
#import "CategoryEventStreamViewController.h"

#import "CategoryFilter.h"

//#import "LokaliteEventStream.h"
#import "LokaliteCategoryStream.h"
#import "LokaliteSearchStream.h"

#import "TableViewImageFetcher.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface AllEventsViewController ()
@property (nonatomic, retain) TableViewImageFetcher *imageFetcher;

#pragma mark - View initialization

- (void)initializeNavigationItem;

@end


@implementation AllEventsViewController

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

    [self setShowsSearchBar:YES];
    [self setCanSearchServer:YES];
    [[[self searchDisplayController] searchResultsTableView]
     setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self setShowsCategoryFilter:YES];
    [self setRequiresLocation:YES];
}

#pragma mark - LokaliteStreamViewController implementation

#pragma mark Configuring the view

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.events", nil);
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

- (UITableViewCell *)tableViewCellInstanceAtIndexPath:(NSIndexPath *)indexPath
                                         forTableView:(UITableView *)tableView
                                      reuseIdentifier:(NSString *)identifier
{
    return [EventTableViewCell instanceFromNib];
}

- (void)configureCell:(EventTableViewCell *)cell
          inTableView:(UITableView *)tableView
            forObject:(Event *)event
{
    [cell configureCellForEvent:event displayDistance:!![self currentLocation]];

    UIImage *image = [event image];
    if (!image) {
        NSURL *url = [event fullImageUrl];

        [[self imageFetcher] fetchImageDataAtUrl:url
                                       tableView:tableView
                             dataReceivedHandler:
         ^(NSData *data) {
             [event setImageData:data];
         }
                            tableViewCellHandler:
         ^(UIImage *image, UITableViewCell *tvc, NSIndexPath *path) {
             if ([tvc isKindOfClass:[EventTableViewCell class]]) {
                 EventTableViewCell *cell = (EventTableViewCell *) tvc;
                 if ([[cell eventId] isEqualToNumber:[event identifier]])
                     [[cell eventImageView] setImage:image];
             }
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

#pragma mark - Search - remote

- (NSPredicate *)predicateForQueryString:(NSString *)queryString
{
    return [Event predicateForSearchString:queryString
                             includeEvents:YES
                         includeBusinesses:YES];
}

- (LokaliteStream *)remoteSearchLokaliteStreamInstanceForKeywords:
    (NSString *)keywords
{
    return [LokaliteSearchStream eventSearchStreamWithKeywords:keywords
                                                       context:[self context]];
}

#pragma mark - Working with category filters

- (NSArray *)categoryFilters
{
    return [CategoryFilter defaultEventFilters];
}

- (void)didSelectCategoryFilter:(CategoryFilter *)filter
{
    NSManagedObjectContext *moc = [self context];

    NSString *serverFilter = [filter serverFilter];
    NSString *name = [filter name];
    LokaliteStream *stream =
        [LokaliteCategoryStream eventStreamWithCategoryName:serverFilter
                                                    context:moc];
    CategoryEventStreamViewController *controller =
        [[CategoryEventStreamViewController alloc] initWithCategoryName:name
                                                         lokaliteStream:stream
                                                                context:moc];
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
    return [Event dateTableViewSortDescriptors];
}

#pragma mark Fetching data from the network

- (void)processNextBatchOfFetchedObjects:(NSArray *)events
                              pageNumber:(NSInteger)pageNumber
{
    [super processNextBatchOfFetchedObjects:events pageNumber:pageNumber];
}

- (void)processObjectFetchError:(NSError *)error
                     pageNumber:(NSInteger)pageNumber
{
    [super processObjectFetchError:error pageNumber:pageNumber];

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

- (LokaliteStream *)lokaliteStreamInstance
{
    return [LokaliteCategoryStream eventStreamWithCategoryName:nil
                                                       context:[self context]];
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setLeftBarButtonItem:[self refreshButtonItem]];
    [[self navigationItem] setRightBarButtonItem:[self mapViewButtonItem]];
}

#pragma mark - Accessors

- (TableViewImageFetcher *)imageFetcher
{
    if (!imageFetcher_)
        imageFetcher_ = [[TableViewImageFetcher alloc] init];

    return imageFetcher_;
}

@end
