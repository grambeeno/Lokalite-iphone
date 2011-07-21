//
//  EventsViewController.m
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventsViewController.h"

#import "EventTableViewCell.h"

#import "LokaliteEventStream.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"
#import "EventTableViewCell.h"

#import "EventDetailsViewController.h"

#import "CategoryFilter.h"

#import "DataFetcher.h"

#import "LokaliteAppDelegate.h"

#import "SDKAdditions.h"


static const NSInteger CATEGORY_FILTER_TAG_INDEX_OFFSET = 100;


@interface EventsViewController ()

@property (nonatomic, copy) NSArray *categoryFilters;
@property (nonatomic, assign) NSInteger selectedCategoryFilterIndex;

@property (nonatomic, retain) LokaliteEventStream *stream;

@property (nonatomic, retain) NSFetchedResultsController *dataController;
@property (nonatomic, assign) BOOL hasFetchedData;

@property (nonatomic, copy) NSArray *searchResults;

#pragma mark - View initialization

- (void)initializeTableView;
- (void)initializeSearchBar;

#pragma mark - View configuration

- (void)configureTitleViewForCategoryFilter:(CategoryFilter *)filter;

- (NSIndexPath *)dataControllerIndexPathForTableViewIndexPath:(NSIndexPath *)ip
                                                  inTableView:(UITableView *)tv;
- (NSIndexPath *)tableViewIndexPathForDataControllerIndexPath:(NSIndexPath *)ip
                                                  inTableView:(UITableView *)tv;
- (void)configureCell:(EventTableViewCell *)cell forEvent:(Event *)event;

- (void)displayActivityView;
- (void)displayActivityViewWithCompletion:(void (^)(void))completion;
- (void)hideActivityView;
- (void)hideActivityViewWithCompletion:(void (^)(void))completion;

#pragma mark - Fetching data

- (void)fetchNextSetOfEvents;
- (void)fetchImageForEvent:(Event *)event;

#pragma mark - Processing received data

- (void)processReceivedError:(NSError *)error;

#pragma mark - Managing the fetched results controller

- (void)loadDataController;

@end

@implementation EventsViewController

@synthesize categoryFilters = categoryFilters_;
@synthesize selectedCategoryFilterIndex = selectedCategoryFilterIndex_;

@synthesize context = context_;

@synthesize stream = stream_;

@synthesize dataController = dataController_;
@synthesize hasFetchedData = hasFetchedData_;

@synthesize searchResults = searchResults_;

@synthesize categoryTableViewCell = categoryTableViewCell_;
@synthesize categoryHeaderView = categoryHeaderView_;

#pragma mark - Memory management

- (void)dealloc
{
    [categoryFilters_ release];

    [context_ release];

    [stream_ release];

    [dataController_ release];

    [searchResults_ release];

    [categoryTableViewCell_ release];
    [categoryHeaderView_ release];

    [super dealloc];
}

#pragma mark - UI events

- (void)didChangeCategoryFilter:(UIButton *)button
{
    const NSInteger indexOffset = CATEGORY_FILTER_TAG_INDEX_OFFSET;

    NSInteger oldFilterIndex = [self selectedCategoryFilterIndex];
    NSInteger oldFilterButtonTag = oldFilterIndex + indexOffset;
    CategoryFilter *oldFilter =
        [[self categoryFilters] objectAtIndex:oldFilterIndex];
    UIButton *oldButton = (UIButton *)
        [[self categoryHeaderView] viewWithTag:oldFilterButtonTag];
    [oldButton setImage:[oldFilter buttonImage] forState:UIControlStateNormal];

    NSInteger filterButtonTag = [button tag];
    NSInteger filterIndex = filterButtonTag - indexOffset;
    CategoryFilter *filter = [[self categoryFilters] objectAtIndex:filterIndex];
    [button setImage:[filter selectedButtonImage]
            forState:UIControlStateNormal];

    [self configureTitleViewForCategoryFilter:filter];
    [self setSelectedCategoryFilterIndex:filterIndex];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeTableView];
    [self initializeSearchBar];
    [self setHasFetchedData:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self hasFetchedData] == NO) {
        [self displayActivityViewWithCompletion:^{
            [self fetchNextSetOfEvents];
        }];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    return io == UIInterfaceOrientationPortrait;
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if ([self tableView] == tableView)
        return [[[self dataController] sections] count];
    else
        return 1;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    NSInteger nrows = 0;

    if ([self tableView] == tableView) {
        id <NSFetchedResultsSectionInfo> sectionInfo =
            [[[self dataController] sections] objectAtIndex:section];
        nrows = [sectionInfo numberOfObjects];
    } else
        nrows = [[self searchResults] count];

    return nrows + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0 && [indexPath row] == 0)
        return [self categoryTableViewCell];
    else {
        indexPath =
            [self dataControllerIndexPathForTableViewIndexPath:indexPath
                                                   inTableView:tableView];

        static NSString *CellIdentifier = nil;
        if (!CellIdentifier)
            CellIdentifier = [[EventTableViewCell defaultReuseIdentifier] copy];

        EventTableViewCell *cell = (EventTableViewCell *)
            [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil)
            cell = [EventTableViewCell instanceFromNib];

        Event *event =
            [self tableView] == tableView ?
            [[self dataController] objectAtIndexPath:indexPath] :
            [[self searchResults] objectAtIndex:[indexPath row]];
        [self configureCell:cell forEvent:event];

        return cell;
    }
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = nil;
    indexPath = [self dataControllerIndexPathForTableViewIndexPath:indexPath
                                                       inTableView:tableView];
    if (tableView == [self tableView])
        event = [[self dataController] objectAtIndexPath:indexPath];
    else
        event = [[self searchResults] objectAtIndex:[indexPath row]];

    EventDetailsViewController *controller =
        [[EventDetailsViewController alloc] initWithEvent:event];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

#pragma mark - NSFetchedResultsControllerDelegate implementation

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller
   didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath
     forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath
{
    UITableView *tableView = [self tableView];

    indexPath =
        [self tableViewIndexPathForDataControllerIndexPath:indexPath
                                               inTableView:[self tableView]];
    newIndexPath =
        [self tableViewIndexPathForDataControllerIndexPath:newIndexPath
                                               inTableView:[self tableView]];

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                   withRowAnimation:UITableViewRowAnimationBottom];
            break;
 
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationTop];
            break;
 
        case NSFetchedResultsChangeUpdate: {
            EventTableViewCell *cell = (EventTableViewCell *)
                [tableView cellForRowAtIndexPath:indexPath];
            [self configureCell:cell forEvent:anObject];
        }
            break;
 
        case NSFetchedResultsChangeMove:
            [tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                   withRowAnimation:UITableViewRowAnimationFade];
            [tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                   withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];
}

#pragma mark - UISearchBarDelegate implementation

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self setSearchResults:nil];
}

#pragma mark - UISearchDisplayDelegate implementation

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)ctlr
{
    [self setSearchResults:[NSArray array]];
}

- (void)searchLocalContentForSearchString:(NSString *)searchString
                              searchScope:(NSInteger)scopeIndex
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    searchString = [searchString stringByTrimmingCharactersInSet:whitespace];

    if ([searchString length]) {
        BOOL includeEvents = scopeIndex == 0 || scopeIndex == 2;
        BOOL includeBusinesses = scopeIndex == 1 || scopeIndex == 2;

        NSPredicate *pred = [Event predicateForSearchString:searchString
                                              includeEvents:includeEvents
                                          includeBusinesses:includeBusinesses];
        NSArray *objects = [[self dataController] fetchedObjects];
        objects = [objects filteredArrayUsingPredicate:pred];
        [self setSearchResults:objects];

        NSLog(@"Search string '%@' matches %d events", searchString,
              [objects count]);
    }

}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchString:(NSString *)searchString
{
    NSInteger scopeIndex = [[controller searchBar] selectedScopeButtonIndex];
    [self searchLocalContentForSearchString:searchString
                                searchScope:scopeIndex];

    return YES;
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
    shouldReloadTableForSearchScope:(NSInteger)searchOption
{
    NSString *searchString = [[controller searchBar] text];
    [self searchLocalContentForSearchString:searchString
                                searchScope:searchOption];

    return YES;
}

#pragma mark - View initialization

- (void)initializeCategoryFilter
{
    NSArray *categories = [self categoryFilters];
    NSInteger selectedFilterIndex = 0;
    [self setSelectedCategoryFilterIndex:selectedFilterIndex];

    static const CGFloat buttonHeight = 50, buttonWidth = 50;
    UIScrollView *categoryView = [self categoryHeaderView];
    CGRect frame = [categoryView frame];
    CGFloat margin = round((frame.size.height - buttonHeight) / 2);
    __block CGPoint point = CGPointMake(margin, 8);

    // margin of 30 gives us 15 points of space on the left or right of the
    // scroll view, and 30 points between buttons per page
    margin = 30;

    [categories enumerateObjectsUsingBlock:
     ^(CategoryFilter *filter, NSUInteger idx, BOOL *stop) {
         BOOL isSelectedFilter = selectedFilterIndex == idx;

         if (isSelectedFilter)
             [self configureTitleViewForCategoryFilter:filter];

         CGRect buttonFrame =
            CGRectMake(point.x, point.y, buttonWidth, buttonHeight);
         UIButton *button =
            [UIButton lokaliteCategoryButtonWithFrame:buttonFrame];

         UIImage *buttonImage =
            isSelectedFilter ?
            [filter selectedButtonImage] : [filter buttonImage];
         [button setImage:buttonImage forState:UIControlStateNormal];

         [button addTarget:self
                    action:@selector(didChangeCategoryFilter:)
          forControlEvents:UIControlEventTouchUpInside];

         [button setTag:idx + CATEGORY_FILTER_TAG_INDEX_OFFSET];

         [categoryView addSubview:button];

         static const CGFloat LABEL_MARGIN = 13;
         CGRect labelFrame =
            CGRectMake(buttonFrame.origin.x - LABEL_MARGIN,
                       buttonFrame.origin.y + buttonFrame.size.height + 3,
                       buttonFrame.size.width + LABEL_MARGIN * 2,
                       14);
         UILabel *nameLabel = [[UILabel alloc] initWithFrame:labelFrame];
         [nameLabel setBackgroundColor:[UIColor whiteColor]];
         [nameLabel setFont:[UIFont systemFontOfSize:12]];
         [nameLabel setText:[filter shortName]];
         [nameLabel setTextAlignment:UITextAlignmentCenter];
         [categoryView addSubview:nameLabel];
         [nameLabel release], nameLabel = nil;

         point.x += buttonWidth + margin;
     }];

    // set the content size to an even number of pages
    CGFloat totalButtonWidths = point.x + margin;
    NSInteger npages = ceil(totalButtonWidths / frame.size.width);
    CGSize contentSize =
        CGSizeMake(frame.size.width * npages, frame.size.height);
    [categoryView setContentSize:contentSize];
}

- (void)initializeTableView
{
    CGFloat rowHeight = [EventTableViewCell cellHeight];
    [[self tableView] setRowHeight:rowHeight];
    [[[self searchDisplayController]
      searchResultsTableView] setRowHeight:rowHeight];

    [[self categoryHeaderView] setScrollsToTop:NO];
    [self initializeCategoryFilter];
}

- (void)initializeSearchBar
{
    [[[self searchDisplayController] searchBar] setSelectedScopeButtonIndex:2];
}

#pragma mark - View configuration

- (void)configureTitleViewForCategoryFilter:(CategoryFilter *)filter
{
    [self setTitle:[filter name]];

    UIBarButtonItem *backButtonItem =
        [[UIBarButtonItem alloc] initWithTitle:[filter shortName]
                                         style:UIBarButtonItemStylePlain
                                        target:nil
                                        action:nil];
    [[self navigationItem] setBackBarButtonItem:backButtonItem];
    [backButtonItem release], backButtonItem = nil;
}

- (NSIndexPath *)dataControllerIndexPathForTableViewIndexPath:(NSIndexPath *)ip
                                                  inTableView:(UITableView *)tv
{
    if (tv == [self tableView])
        return [NSIndexPath indexPathForRow:[ip row] - 1
                                  inSection:[ip section]];
    else
        return ip;
}

- (NSIndexPath *)tableViewIndexPathForDataControllerIndexPath:(NSIndexPath *)ip
                                                  inTableView:(UITableView *)tv
{
    if (tv == [self tableView])
        return [NSIndexPath indexPathForRow:[ip row] + 1
                                  inSection:[ip section]];
    else
        return ip;
}

- (void)configureCell:(EventTableViewCell *)cell forEvent:(Event *)event
{
    [cell configureCellForEvent:event];

    NSData *imageData = [event imageData];
    if (imageData)
        [[cell eventImageView] setImage:[UIImage imageWithData:imageData]];
    else {
        [[cell eventImageView] setImage:nil];
        [self fetchImageForEvent:event];
    }
}

- (void)displayActivityView
{
    [self displayActivityViewWithCompletion:nil];
}

- (void)displayActivityViewWithCompletion:(void (^)(void))completion
{
    LokaliteAppDelegate *delegate =
        (LokaliteAppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate displayActivityViewAnimated:YES completion:completion];
}

- (void)hideActivityView
{
    [self hideActivityViewWithCompletion:nil];
}

- (void)hideActivityViewWithCompletion:(void (^)(void))completion
{
    LokaliteAppDelegate *delegate =
        (LokaliteAppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate hideActivityViewAnimated:YES completion:completion];
}

#pragma mark - Fetching data

- (void)fetchNextSetOfEvents
{
    [[self stream] fetchNextBatchWithResponseHandler:
     ^(NSArray *events, NSError *error) {
         if (events) {
             [self loadDataController];
             if (![self hasFetchedData])
                 [[self tableView] reloadData];
         } else if (error)
             [self processReceivedError:error];

         if (![self hasFetchedData])
             [self hideActivityView];

         [self setHasFetchedData:YES];
     }];
}

- (void)fetchImageForEvent:(Event *)event
{
    [[UIApplication sharedApplication] networkActivityIsStarting];

    NSURL *baseUrl = [[self stream] baseUrl];
    NSString *urlPath = [event imageUrl];
    NSURL *url = [baseUrl URLByAppendingPathComponent:urlPath];

    UITableView *tableView = [self tableView];
    NSArray *events = [[self dataController] fetchedObjects];
    [DataFetcher fetchDataAtUrl:url responseHandler:
     ^(NSData *data, NSError *error) {
         [[UIApplication sharedApplication] networkActivityDidFinish];

         if (data) {
             __block UIImage *image = nil;
             NSArray *visibleCells = [tableView visibleCells];
             [visibleCells enumerateObjectsUsingBlock:
              ^(UITableViewCell *tvc, NSUInteger idx, BOOL *stop) {
                  if ([tvc isKindOfClass:[EventTableViewCell class]]) {
                      EventTableViewCell *cell = (EventTableViewCell *) tvc;

                      NSIndexPath *ip = [tableView indexPathForCell:cell];
                      ip =
                          [self
                           dataControllerIndexPathForTableViewIndexPath:ip
                           inTableView:tableView];

                      Event *e = [events objectAtIndex:[ip row]];
                      if ([[e imageUrl] isEqualToString:urlPath]) {
                          if (!image)
                              image = [UIImage imageWithData:data];
                          [[cell eventImageView] setImage:image];
                          [e setImageData:data];
                      }
                  }
             }];
         } else
             NSLog(@"WARNING: Failed to download image data for event: %@: %@",
                   [event identifier], [error detailedDescription]);
    }];
}

#pragma mark - Processing received data

- (void)processReceivedError:(NSError *)error
{
    NSLog(@"Received error: %@", error);
    NSString *title = NSLocalizedString(@"featured.fetch.failed", nil);
    NSString *message = [error localizedDescription];
    NSString *cancel = NSLocalizedString(@"global.dismiss", nil);
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:message
                                                   delegate:nil
                                          cancelButtonTitle:cancel
                                          otherButtonTitles:nil];
    [alert show];
    [alert release], alert = nil;
}

#pragma mark - Managing the fetched results controller

- (void)loadDataController
{
    [self setDataController:nil];

    NSManagedObjectContext *context = [self context];
    NSFetchRequest *req = [[NSFetchRequest alloc] init];

    NSEntityDescription *entity =
        [NSEntityDescription entityForName:@"Event"
                    inManagedObjectContext:context];
    
    [req setEntity:entity];

    NSSortDescriptor *sd =
        [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:YES];
    NSArray *sds = [NSArray arrayWithObjects:sd, nil];
    [req setSortDescriptors:sds];

    NSFetchedResultsController *controller =
        [[NSFetchedResultsController alloc] initWithFetchRequest:req
                                            managedObjectContext:context
                                              sectionNameKeyPath:nil
                                                       cacheName:nil];
    NSError *error = nil;
    if ([controller performFetch:&error]) {
        dataController_ = controller;
        [dataController_ setDelegate:self];
    } else {
        [controller release], controller = nil;
        NSLog(@"Failed to fetch event objects: %@",
              [error detailedDescription]);
    }
}

#pragma mark - Accessors

- (NSArray *)categoryFilters
{
    if (!categoryFilters_)
        categoryFilters_ = [[CategoryFilter defaultFilters] copy];

    return categoryFilters_;
}


- (LokaliteEventStream *)stream
{
    if (!stream_)
        stream_ = [LokaliteEventStream streamWithContext:[self context]];

    return stream_;
}

@end
