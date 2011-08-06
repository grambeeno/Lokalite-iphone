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

#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"

#import "LokaliteEventStream.h"

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

- (NSPredicate *)predicateForQueryString:(NSString *)queryString
{
    return [Event predicateForSearchString:queryString
                             includeEvents:YES
                         includeBusinesses:NO];
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
    NSLog(@"Freshness date: %@", date);

    LokaliteDownloadSource *source = [[self lokaliteStream] downloadSource];
    NSString *sourceName = [source name];

    /*
    NSString *formatString =
        @"(ALL downloadSources.name == %@) AND (ALL downloadSources.lastUpdated >= %@)";

    NSPredicate *p = [NSPredicate predicateWithFormat:formatString, sourceName, date];
    NSArray *currentMatches = [Event findAllWithPredicate:p inContext:context];
    NSLog(@"Freshness date: %@", date);
    NSLog(@"%d current matches", [currentMatches count]);
    for (Event *event in currentMatches) {
        NSLog(@"%@: %@ (%@)", [event identifier], [event name],
              [event isFeatured] ? @"featured" : @"not featured");
        NSLog(@"%@", [event downloadSources]);
    }

    return p;
     */

    /*
    return [NSPredicate predicateForDownloadSourceName:sourceName
                                       lastUpdatedDate:date];
     */

    NSPredicate *tagPred =
        [NSPredicate predicateWithFormat:
         @"ANY downloadSources.name == %@", sourceName];
    NSPredicate *datePred =
        [NSPredicate predicateWithFormat:
         @"ANY downloadSources.lastUpdated >= %@", date];
    NSArray *preds = [NSArray arrayWithObjects:tagPred, datePred, nil];

    NSPredicate *p = [NSCompoundPredicate andPredicateWithSubpredicates:preds];

    void (^print_event)(Event *event) = ^(Event *event) {
        NSLog(@"%@: %@ (%@)", [event identifier], [event name],
              [event isFeatured] ? @"featured" : @"not featured");
        NSLog(@"%@", [event downloadSources]);
    };
    void (^print_events)(NSArray *) = ^(NSArray *events) {
        for (Event *event in events)
            print_event(event);
    };

    NSArray *currentMatches = [Event findAllWithPredicate:p inContext:context];
    NSLog(@"%d current matches", [currentMatches count]);
    print_events(currentMatches);

    NSArray *tagMatches = [currentMatches filteredArrayUsingPredicate:tagPred];
    NSLog(@"Objects matching tag predicate: %d", [tagMatches count]);
    print_events(tagMatches);

    NSArray *dateMatches = [currentMatches filteredArrayUsingPredicate:datePred];
    NSLog(@"Objects matching date predicate: %d", [dateMatches count]);
    print_events(dateMatches);

    return p;
}

- (NSArray *)dataControllerSortDescriptors
{
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"endDate"
                                                          ascending:YES];
    NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                          ascending:YES];

    return [NSArray arrayWithObjects:sd1, sd2, nil];
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
    return [LokaliteEventStream streamWithContext:[self context]];
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
}

@end
