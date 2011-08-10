//
//  FeaturedEventsViewController.m
//  Lokalite
//
//  Created by John Debay on 7/27/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "FeaturedEventsViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"

#import "LokaliteFeaturedEventStream.h"

#import "TableViewImageFetcher.h"

#import "MapDisplayController.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface FeaturedEventsViewController ()

@property (nonatomic, retain) TableViewImageFetcher *imageFetcher;

#pragma mark - View initialization

- (void)initializeNavigationItem;

@end


@implementation FeaturedEventsViewController

@synthesize mapView = mapView_;
@synthesize mapViewController = mapViewController_;

@synthesize imageFetcher = imageFetcher_;

#pragma mark - Memory management

- (void)dealloc
{
    [mapView_ release];
    [mapViewController_ release];

    [imageFetcher_ release];

    [super dealloc];
}

#pragma mark - LokaliteStreamViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];
}

#pragma mark Configuring the view

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.featured", nil);
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
    [cell configureCellForEvent:event];

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

    NSPredicate *all =
        [NSPredicate predicateForDownloadSourceName:sourceName
                                    lastUpdatedDate:date];
    NSPredicate *featured =
        [NSPredicate predicateWithFormat:@"featured == YES"];
    NSArray *subpredicates = [NSArray arrayWithObjects:featured, all, nil];

    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}

- (NSArray *)dataControllerSortDescriptors
{
    return [Event defaultTableViewSortDescriptors];
}

#pragma mark Fetching data from the network

- (void)processNextBatchOfFetchedObjects:(NSArray *)events
                              pageNumber:(NSInteger)pageNumber
{
    [super processNextBatchOfFetchedObjects:events pageNumber:pageNumber];

    if (pageNumber == 1) {
        NSManagedObjectContext *context = [self context];

        NSPredicate *pred = [self dataControllerPredicate];
        NSArray *allEvents = [Event findAllWithPredicate:pred
                                               inContext:context];

        [LokaliteObjectBuilder replaceLokaliteObjects:allEvents
                                          withObjects:events
                                      usingValueOfKey:@"identifier"
                                     remainingHandler:
         ^(Event *event) {
             NSLog(@"Deleting event: %@: %@", [event identifier], [event name]);
             if ([[event featured] boolValue])
                 [context deleteObject:event];
         }];
    }
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
    return [LokaliteFeaturedEventStream streamWithContext:[self context]];
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setLeftBarButtonItem:[self refreshButtonItem]];
    [[self navigationItem] setRightBarButtonItem:
     [self toggleMapViewButtonItem]];
}

#pragma mark - Account events

- (BOOL)shouldResetForAccountAddition:(LokaliteAccount *)account
{
    return YES;
}

- (BOOL)shouldResetForAccountDeletion:(LokaliteAccount *)account
{
    return YES;
}

#pragma mark - Accessors

- (TableViewImageFetcher *)imageFetcher
{
    if (!imageFetcher_)
        imageFetcher_ = [[TableViewImageFetcher alloc] init];

    return imageFetcher_;
}

@end
