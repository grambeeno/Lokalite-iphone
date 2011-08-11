//
//  PlacesViewController.m
//  Lokalite
//
//  Created by John Debay on 7/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlacesViewController.h"

#import "LokaliteAccount.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"
#import "BusinessDetailsViewController.h"

#import "PlaceTableViewCell.h"

#import "LokaliteStream.h"
#import "LokaliteSearchStream.h"
#import "LokalitePlacesStream.h"

#import "TableViewImageFetcher.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface PlacesViewController ()

@property (nonatomic, retain) TableViewImageFetcher *imageFetcher;

#pragma mark - View initialization

- (void)initializeNavigationItem;

@end


@implementation PlacesViewController

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
    [self setShowsCategoryFilter:YES];
}

#pragma mark - LokaliteStreamViewController implementation

#pragma mark Configuring the view

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.places", nil);
}

#pragma mark - Configuring the table view

- (void)initializeTableView:(UITableView *)tableView
{
    [super initializeTableView:tableView];

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
    [cell configureCellForPlace:place];

    UIImage *image = [place image];
    if (image)
        [[cell placeImageView] setImage:image];
    else {
        NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
        NSString *urlPath = [place imageUrl];
        NSURL *url = [baseUrl URLByAppendingPathComponent:urlPath];

        [[self imageFetcher] fetchImageDataAtUrl:url
                                       tableView:tableView
                             dataReceivedHandler:
         ^(NSData *data) {
             [place setImageData:data];
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
             NSLog(@"WARNING: Failed to fetch place image at: %@", url);
         }];
    }
}

- (void)displayDetailsForObject:(Business *)place
{
    BusinessDetailsViewController *controller =
        [[BusinessDetailsViewController alloc] initWithBusiness:place];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

#pragma mark - Search - remote

- (NSPredicate *)predicateForQueryString:(NSString *)queryString
{
    return [Business predicateForSearchString:queryString];
}

- (LokaliteStream *)remoteSearchLokaliteStreamInstanceForKeywords:
    (NSString *)keywords
{
    return [LokaliteSearchStream placesSearchStreamWithKeywords:keywords
                                                        context:[self context]];
}

#pragma mark - Working with category filters

- (NSArray *)categoryFilters
{
    return [CategoryFilter defaultPlaceFilters];
}

- (void)didSelectCategoryFilter:(CategoryFilter *)filter
{
    /*
    NSManagedObjectContext *context = [self context];

    NSString *serverFilter = [filter serverFilter];
    LokaliteStream *stream =
        [LokaliteCategoryEventStream streamWithCategoryName:serverFilter
                                                    context:context];
    SimpleEventsViewController *controller =
        [[SimpleEventsViewController alloc] initWithCategoryName:[filter name]
                                                  lokaliteStream:stream
                                                         context:context];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
     */
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
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                         ascending:YES];
    return [NSArray arrayWithObject:sd];
}

- (LokaliteStream *)lokaliteStreamInstance
{
    return [LokalitePlacesStream streamWithContext:[self context]];
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setRightBarButtonItem:[self mapViewButtonItem]];
}

#pragma mark - Account events

- (BOOL)shouldResetForAccountAddition:(LokaliteAccount *)account
{
    return NO;
}

#pragma mark - Accessors

- (TableViewImageFetcher *)imageFetcher
{
    if (!imageFetcher_)
        imageFetcher_ = [[TableViewImageFetcher alloc] init];

    return imageFetcher_;
}

@end
