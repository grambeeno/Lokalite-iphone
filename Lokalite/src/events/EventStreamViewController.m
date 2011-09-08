//
//  EventStreamViewController.m
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventStreamViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"

#import "StaticEventListViewController.h"

#import "TableViewImageFetcher.h"
#import "LokaliteApplicationState.h"

#import "LokaliteStream.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface EventStreamViewController ()

@property (nonatomic, retain) TableViewImageFetcher *imageFetcher;

@end


@implementation EventStreamViewController

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
    [[[self searchDisplayController] searchResultsTableView]
     setSeparatorStyle:UITableViewCellSeparatorStyleNone];
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
    [tableView setBackgroundColor:[UIColor tableViewBackgroundColor]];
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
    [cell configureCellForEvent:event displayDistance:[self hasValidLocation]];

    UIImage *image = [event standardImage];
    if (!image)
        [self fetchImageForEvent:event tableView:tableView];
    [[cell eventImageView] setImage:image];
}

- (void)displayDetailsForObject:(Event *)event
{
    EventDetailsViewController *controller =
        [[EventDetailsViewController alloc] initWithEvent:event];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

- (void)displayDetailsForObjectGroup:(NSArray *)group
{
    StaticEventListViewController *controller =
        [[StaticEventListViewController alloc] initWithEvents:group];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

- (NSPredicate *)predicateForQueryString:(NSString *)queryString
{
    return [Event predicateForSearchString:queryString
                             includeEvents:YES
                         includeBusinesses:NO];
}

#pragma mark Working with the error view

- (UIView *)errorViewInstanceForError:(NSError *)error
{
    NoDataView *view = [NoDataView instanceFromNib];
    [[view titleLabel] setText:[self alertViewTitleForError:error]];

    NSString *format =
        NSLocalizedString(@"events.error-view.description.format", nil);
    NSString *description =
        [NSString stringWithFormat:format, [error localizedDescription]];
    [[view descriptionLabel] setText:description];

    return view;
}

- (NSString *)alertViewTitleForError:(NSError *)error
{
    return NSLocalizedString(@"events.error-view.title", nil);
}

#pragma mark Working with the no data view

- (UIView *)noDataViewInstance
{
    NoDataView *view = [NoDataView instanceFromNib];
    [[view titleLabel]
     setText:NSLocalizedString(@"events.no-data-view.title", nil)];
    [[view descriptionLabel]
     setText:NSLocalizedString(@"events.no-data-view.description", nil)];

    return view;
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

- (NSString *)dataControllerSectionNameKeyPath
{
    return @"dateDescription";
}

#pragma mark - Working with event images

- (void)fetchImageForEvent:(Event *)event tableView:(UITableView *)tableView
{
    NSURL *url = [NSURL URLWithString:[event standardImageUrl]];

    [[self imageFetcher] fetchImageDataAtUrl:url
                                   tableView:tableView
                         dataReceivedHandler:
     ^(NSData *data) {
         NSArray *events =
            [self tableView] == tableView ?
            [[self dataController] fetchedObjects] :
            [self searchResults];
         NSString *urlString = [url absoluteString];
         for (Event *event in events)
             if ([[event standardImageUrl] isEqualToString:urlString])
                 [event setStandardImageData:data];
     }
                        tableViewCellHandler:
     ^(UIImage *image, UITableViewCell *tvc, NSIndexPath *path) {
         if ([tvc isKindOfClass:[EventTableViewCell class]]) {
             EventTableViewCell *cell = (EventTableViewCell *) tvc;
             NSString *imageUrl = [cell eventImageUrl];
             if ([imageUrl isEqualToString:[event standardImageUrl]])
                 [[cell eventImageView] setImage:image];
         }
     }
                                errorHandler:
     ^(NSError *error) {
         NSLog(@"WARNING: Failed to fetch place image at: %@: %@", url,
               error);
     }];
}

#pragma mark - Accessors

- (TableViewImageFetcher *)imageFetcher
{
    if (!imageFetcher_)
        imageFetcher_ = [[TableViewImageFetcher alloc] init];

    return imageFetcher_;
}

@end
