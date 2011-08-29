//
//  PlaceStreamViewController.m
//  Lokalite
//
//  Created by John Debay on 8/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlaceStreamViewController.h"

#import "PlaceTableViewCell.h"
#import "BusinessDetailsViewController.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface PlaceStreamViewController ()

@property (nonatomic, retain) TableViewImageFetcher *imageFetcher;

@end


@implementation PlaceStreamViewController

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

    [self setShowsSearchBar:YES];
    [self setCanSearchServer:NO];
    [[[self searchDisplayController] searchResultsTableView]
     setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    [self setShowsCategoryFilter:NO];
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
    [tableView setRowHeight:[PlaceTableViewCell cellHeight]];
}

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView
{
    return [PlaceTableViewCell defaultReuseIdentifier];
}

- (UITableViewCell *)tableViewCellInstanceAtIndexPath:(NSIndexPath *)indexPath
                                         forTableView:(UITableView *)tableView
                                      reuseIdentifier:(NSString *)identifier
{
    return [PlaceTableViewCell instanceFromNib];
}

- (void)configureCell:(PlaceTableViewCell *)cell
          inTableView:(UITableView *)tableView
            forObject:(Business *)place
{
    [cell configureCellForPlace:place
                displayDistance:[self hasValidLocation]];

    UIImage *image = [place standardImage];
    if (!image) {
        NSURL *url = [NSURL URLWithString:[place standardImageUrl]];

        [[self imageFetcher] fetchImageDataAtUrl:url
                                       tableView:tableView
                             dataReceivedHandler:
         ^(NSData *data) {
             [place setStandardImageData:data];
         }
                            tableViewCellHandler:
         ^(UIImage *image, UITableViewCell *tvc, NSIndexPath *path) {
             if ([tvc isKindOfClass:[PlaceTableViewCell class]]) {
                 PlaceTableViewCell *cell = (PlaceTableViewCell *) tvc;
                 if ([[cell placeId] isEqualToNumber:[place identifier]])
                     [[cell placeImageView] setImage:image];
             }
         }
                                    errorHandler:
         ^(NSError *error) {
             NSLog(@"WARNING: Failed to fetch place image at: %@: %@", url,
                   error);
         }];
    }

    [[cell placeImageView] setImage:image];
}

- (void)displayDetailsForObject:(Business *)place
{
    BusinessDetailsViewController *controller =
        [[BusinessDetailsViewController alloc] initWithBusiness:place];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

- (NSPredicate *)predicateForQueryString:(NSString *)queryString
{
    return [Business predicateForSearchString:queryString];
}

#pragma mark Working with the local data store

- (NSString *)lokaliteObjectEntityName
{
    return @"Business";
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
    return
        [self hasValidLocation] ?
        [Business locationTableViewSortDescriptors] :
        [Business nameTableViewSortDescriptors];
}

- (NSString *)dataControllerSectionNameKeyPath
{
    return [self hasValidLocation] ? @"distanceDescription" : nil;
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

#pragma mark - Accessors

- (TableViewImageFetcher *)imageFetcher
{
    if (!imageFetcher_)
        imageFetcher_ = [[TableViewImageFetcher alloc] init];

    return imageFetcher_;
}

@end
