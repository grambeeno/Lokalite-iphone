//
//  LokaliteStreamViewController.m
//  Lokalite
//
//  Created by John Debay on 7/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStreamViewController.h"
#import "LokaliteStream.h"

#import "LokaliteAccount.h"
#import "LokaliteAccount+KeychainAdditions.h"

#import "LokaliteAppDelegate.h"

#import "CategoryFilter.h"
#import "CategoryFilterView.h"

#import "SDKAdditions.h"

@interface LokaliteStreamViewController ()

#pragma mark - Working with the table view

@property (nonatomic, retain) UIView *loadingMoreActivityView;

#pragma mark - Working with the search interface

@property (nonatomic, copy) NSArray *searchResults;

#pragma mark - Working with the category filters

@property (nonatomic, copy) NSArray *loadedCategoryFilters;
@property (nonatomic, retain) CategoryFilterView *categoryFilterView;
@property (nonatomic, retain) UITableViewCell *categoryFilterCell;

#pragma mark - Working with the map view

@property (nonatomic, assign, getter=isShowingMapView) BOOL showingMapView;

#pragma mark - View initialization

- (void)initializeNavigationItem:(UINavigationItem *)navItem;
- (void)initializeTableView:(UITableView *)tableView;
- (void)initializeMapView:(MKMapView *)mapView;
- (void)initializeDataController;

#pragma mark Working with the map view

- (void)transitionFromView:(UIView *)fromView
                    toView:(UIView *)toView
                   options:(UIViewAnimationOptions)options
                  animated:(BOOL)animated
                completion:(void (^)(BOOL completed))completion;

#pragma mark - Account events

- (void)processAccountAddition:(LokaliteAccount *)account;
- (void)processAccountDeletion:(LokaliteAccount *)account;

#pragma mark - Fetching data from the network

@property (nonatomic, assign) BOOL isFetchingData;

- (void)fetchInitialSetOfObjectsIfNecessary;

#pragma mark - Persistence management

- (void)loadDataController;
- (void)deleteAllStreamObjects;
- (void)managedObjectContextDidChange:(NSNotification *)notification;
- (void)subscribeForNotificationsForContext:(NSManagedObjectContext *)context;
- (void)unsubscribeForNotoficationsForContext:(NSManagedObjectContext *)context;

#pragma mark - Application notifications

- (void)subscribeForApplicationLifecycleNotifications;
- (void)unsubscribeForApplicationLifecycleNotifications;

@end


@implementation LokaliteStreamViewController

@synthesize showsSearchBar = showsSearchBar_;
@synthesize showsCategoryFilter = showsCategoryFilter_;

@synthesize loadingMoreActivityView = loadingMoreActivityView_;

@synthesize searchResults = searchResults_;

@synthesize loadedCategoryFilters = loadedCategoryFilters_;
@synthesize categoryFilterView = categoryFilterView_;
@synthesize categoryFilterCell = categoryFilterCell_;

@synthesize showingMapView = showingMapView_;
@synthesize mapView = mapView_;
@synthesize mapViewController = mapViewController_;
@synthesize toggleMapViewButtonItem = toggleMapViewButtonItem_;

@synthesize context = context_;
@synthesize dataController = dataController_;

@synthesize lokaliteStream = lokaliteStream_;
//@synthesize showsDataBeforeFirstFetch = showsDataBeforeFirstFetch_;
@synthesize isFetchingData = isFetchingData_;

#pragma mark - Memory management

- (void)dealloc
{
    [self unsubscribeForApplicationLifecycleNotifications];
    [self unsubscribeForNotoficationsForContext:context_];

    [loadingMoreActivityView_ release];

    [searchResults_ release];

    [loadedCategoryFilters_ release];
    [categoryFilterView_ release];
    [categoryFilterCell_ release];

    [mapView_ release];
    [mapViewController_ release];
    [toggleMapViewButtonItem_ release];

    [context_ release];
    [dataController_ release];
    [lokaliteStream_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        showsSearchBar_ = NO;
        showsCategoryFilter_ = NO;

        //showsDataBeforeFirstFetch_ = NO;
        isFetchingData_ = NO;

        showingMapView_ = NO;
        [self setTitle:[self titleForView]];
    }

    return self;
}

#pragma mark - Button actions

- (void)refresh:(id)sender
{
    [self fetchInitialSetOfObjectsIfNecessary];
}

- (void)toggleMapView:(id)sender
{
    [self toggleMapViewAnimated:YES];
}

- (void)loadMoreButtonTapped:(id)sender
{
    if (![self isFetchingData])
        [self fetchNextSetOfObjectsWithCompletion:nil];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self subscribeForNotificationsForContext:[self context]];
    [self subscribeForApplicationLifecycleNotifications];

    [self loadDataController];

    [self initializeNavigationItem:[self navigationItem]];
    [self initializeTableView:[self tableView]];
    [self initializeMapView:[self mapView]];
    [self initializeDataController];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self isShowingMapView]) {
        // HACK: this fixes a bug when tapping a map annotation; when tapping
        // the back button on the detail view, the table view is visible unless
        // the transition is run again (done here with no animation).
        [self transitionFromView:[self tableView]
                          toView:[self mapView]
                         options:0
                        animated:NO
                      completion:nil];
    }

    [self fetchInitialSetOfObjectsIfNecessary];
}

#pragma mark - UIScrollViewDelegate implementation

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    UITableView *tableView = [self tableView];
    if (![self isFetchingData] && [tableView tableFooterView]) {
        CGPoint contentOffset = [tableView contentOffset];
        CGRect footerFrame = [[tableView tableFooterView] frame];
        CGRect frame = [tableView frame];

        BOOL visible =
            footerFrame.origin.y <= (contentOffset.y + frame.size.height);

        if (visible)
            [self loadMoreButtonTapped:self];
    }
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
        nrows = [sectionInfo numberOfObjects] + 1;
    } else
        nrows = [[self searchResults] count];

    return nrows;

}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] == 0 && [indexPath row] == 0)
        return [self categoryFilterCell];
    else {
        NSString *reuseIdentifier = [self reuseIdentifierForIndexPath:indexPath
                                                          inTableView:tableView];
        UITableViewCell *cell =
            [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
        if (cell == nil)
            cell = [self tableViewCellInstanceForTableView:tableView
                                           reuseIdentifier:reuseIdentifier];

        id<MappableLokaliteObject> obj = nil;

        if ([self tableView] == tableView)
            obj = [[self dataController] objectAtIndexPath:indexPath];
        else
            obj = [[self searchResults] objectAtIndex:[indexPath row]];

        [self configureCell:cell forObject:obj];

        return cell;
    }
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<MappableLokaliteObject> obj = nil;

    if ([self tableView] == tableView)
        obj = [[self dataController] objectAtIndexPath:indexPath];
    else
        obj = [[self searchResults] objectAtIndex:[indexPath row]];

    [self displayDetailsForObject:obj];
}

#pragma mark - UISearchBarDelegate implementation

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self setSearchResults:nil];
}

#pragma mark - UISearchDisplayControllerDelegate implementation

- (void)searchDisplayControllerWillBeginSearch:(UISearchDisplayController *)ctlr
{
    [self setSearchResults:[NSArray array]];

    //
    // HACK: This configuration needs to be called every time a search begins.
    //       I'm not sure why. Calling it only in "loadSearchBar" gives a
    //       correct row height and separator style for the first search, but if
    //       the user cancels and then performs a second search, the row height
    //       reverts to the default value. I assume this is because the table
    //       view is destroyed and recreated?
    //
    [self initializeTableView:[ctlr searchResultsTableView]];
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller 
    shouldReloadTableForSearchString:(NSString *)searchString
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    searchString = [searchString stringByTrimmingCharactersInSet:whitespace];

    if ([searchString length]) {
        NSPredicate *pred = [self predicateForQueryString:searchString];
        NSArray *objects = [[self dataController] fetchedObjects];
        objects = [objects filteredArrayUsingPredicate:pred];
        [self setSearchResults:objects];

        NSLog(@"Search string '%@' matches %d events", searchString,
              [objects count]);
    }

    return YES;
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

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                   withRowAnimation:UITableViewRowAnimationBottom];
            break;
 
        case NSFetchedResultsChangeDelete: {
            NSArray *paths = [NSArray arrayWithObject:indexPath];
            [tableView deleteRowsAtIndexPaths:paths
                       withRowAnimation:UITableViewRowAnimationTop];
        }
            break;
 
        case NSFetchedResultsChangeUpdate: {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            // HACK: The data controller cannot be accessed with the
            // provided index path; doing so causes a crash. I don't know
            // why. Accessing the cell via the provided anObject parameter
            // works fine, though.
            [self configureCell:cell forObject:anObject];
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

#pragma mark - MapDisplayControllerDelegate implementation

- (void)mapDisplayController:(MapDisplayController *)controller
             didSelectObject:(id<MappableLokaliteObject>)object
{
    [self displayDetailsForObject:object];
}

#pragma mark - Displaying the activity view

/*
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
 */

#pragma mark - View initialization

- (void)initializeNavigationItem:(UINavigationItem *)navItem
{
    UIBarButtonItem *refreshButton =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                              target:self 
                              action:@selector(refresh:)];
    [navItem setLeftBarButtonItem:refreshButton];
    [refreshButton release], refreshButton = nil;
}

- (void)initializeTableView:(UITableView *)tableView
{
    if (tableView == [self tableView]) {
        BOOL hasFooter =
            /*[self showsDataBeforeFirstFetch] &&*/
            [[self lokaliteStream] hasMorePages];
        [tableView setTableFooterView:
         hasFooter ? [self loadingMoreActivityView] : nil];
    }
}

- (void)initializeMapView:(MKMapView *)mapView
{
}

- (void)initializeDataController
{
    //if ([self showsDataBeforeFirstFetch])
    //    [self loadDataController];
}

#pragma mark - Protected interface

#pragma mark Configuring the view

- (NSString *)titleForView
{
    NSAssert2(NO, @"%@: %@ - Must be implemented by subclsases",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd));    
    return nil;
}

#pragma mark Configuring the table view

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView
{
    return @"TableViewCellIdentifier";
}

- (UITableViewCell *)tableViewCellInstanceForTableView:(UITableView *)tableView
                                       reuseIdentifier:(NSString *)identifier
{
    return [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:identifier] autorelease];
}

- (void)configureCell:(UITableViewCell *)cell forObject:(id<MappableLokaliteObject>)obj
{
    NSAssert2(NO, @"%@: %@ - Must be implemented by subclsases",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)displayDetailsForObject:(id<MappableLokaliteObject>)object
{
    NSAssert2(NO, @"%@: %@ - Must be implemented by subclsases",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

#pragma mark - Searching local results

- (NSPredicate *)predicateForQueryString:(NSString *)queryString
{
    NSAssert2(NO, @"%@: %@ - Must be implemented by subclsases",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    return nil;
}

#pragma mark Working with the map view

- (void)transitionFromView:(UIView *)fromView
                    toView:(UIView *)toView
                   options:(UIViewAnimationOptions)options
                  animated:(BOOL)animated
                completion:(void (^)(BOOL completed))completion
{
    NSTimeInterval duration = animated ? 1 : 0;
    [toView setFrame:[fromView frame]];

    [UIView transitionFromView:fromView
                        toView:toView
                      duration:duration
                       options:options
                    completion:completion];
}

- (void)presentMapViewAnimated:(BOOL)animated
{
    [self transitionFromView:[self tableView]
                      toView:[self mapView]
                     options:UIViewAnimationOptionTransitionCurlUp
                    animated:animated
                  completion:
         ^(BOOL completed) {
             NSArray *objects = [[self dataController] fetchedObjects];
             NSArray *annotations =
                [NSArray mapAnnotationsFromLokaliteObjects:objects];
             [[self mapViewController] setAnnotations:annotations];
             [[[self mapViewController] mapView] setShowsUserLocation:YES];
         }];
    [self setShowingMapView:YES];
}

- (void)dismissMapViewAnimated:(BOOL)animated
{
    [self transitionFromView:[self mapView]
                      toView:[self tableView]
                     options:UIViewAnimationOptionTransitionCurlDown
                    animated:animated
                  completion:^(BOOL completed) {
                      [[self mapViewController] setAnnotations:nil];
                  }];
    [self setShowingMapView:NO];
}

- (void)toggleMapViewAnimated:(BOOL)animated
{
    if ([self isShowingMapView])
        [self dismissMapViewAnimated:animated];
    else
        [self presentMapViewAnimated:animated];
}

#pragma mark - Working with category filters

- (NSArray *)categoryFilters
{
    return [CategoryFilter defaultFilters];
}

#pragma mark - Working with the local data store

- (NSFetchedResultsController *)configuredFetchedResultsController
{
    NSManagedObjectContext *context = [self context];

    NSString *entityName = [self lokaliteObjectEntityName];
    NSEntityDescription *entity =
        [NSEntityDescription entityForName:entityName
                    inManagedObjectContext:[self context]];

    NSPredicate *pred = [self dataControllerPredicate];
    NSArray *sortDescriptors = [self dataControllerSortDescriptors];

    NSFetchRequest *req = [[NSFetchRequest alloc] init];
    [req setEntity:entity];
    [req setPredicate:pred];
    [req setSortDescriptors:sortDescriptors];

    NSString *sectionKeyPath = [self dataControllerSectionNameKeyPath];
    NSString *cacheName = [self dataControllerCacheName];
    NSFetchedResultsController *controller =
        [[NSFetchedResultsController alloc] initWithFetchRequest:req
                                            managedObjectContext:context
                                              sectionNameKeyPath:sectionKeyPath
                                                       cacheName:cacheName];
    [controller autorelease];

    NSError *error = nil;
    if ([controller performFetch:&error])
        [controller setDelegate:self];
    else {
        NSLog(@"%@: %@ - WARNING: Failed to initialize fetched results "
              "controller: %@", NSStringFromClass([self class]),
              NSStringFromSelector(_cmd), [error detailedDescription]);
        controller = nil;
    }

    return controller;
}

- (NSString *)lokaliteObjectEntityName
{
    NSAssert2(NO, @"%@: %@ - Must be implemented by subclasses",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return nil;
}

- (NSPredicate *)dataControllerPredicate
{
    return nil;
}

- (NSArray *)dataControllerSortDescriptors
{
    NSAssert2(NO, @"%@: %@ - Must be implemented by subclasses",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return nil;
}

- (NSString *)dataControllerSectionNameKeyPath
{
    return nil;
}

- (NSString *)dataControllerCacheName
{
    return nil;
}

- (void)loadDataController
{
    [self setDataController:[self configuredFetchedResultsController]];
}

#pragma mark Fetching data from the network

- (void)fetchInitialSetOfObjectsIfNecessary
{
    if (![self isFetchingData]) {
        BOOL fetchNecessary = [[self lokaliteStream] pagesFetched] == 0;
        //BOOL activityViewNecessary =
        //    [[[self dataController] fetchedObjects] count] == 0;

        if (fetchNecessary) {
            //if (activityViewNecessary)
            //    [self displayActivityView];
            [self fetchNextSetOfObjectsWithCompletion:
             ^(NSArray *a, NSError *e) {
                 //if (activityViewNecessary)
                 //    [self hideActivityView];
             }];
        }
    }
}

- (void)fetchNextSetOfObjectsWithCompletion:(void (^)(NSArray *, NSError *))fun
{
    [self setIsFetchingData:YES];

    [[self lokaliteStream] fetchNextBatchWithResponseHandler:
     ^(NSArray *objects, NSError *error) {
         [self setIsFetchingData:NO];

         NSInteger pageNumber = [[self lokaliteStream] pagesFetched];
         if (objects)
             [self processNextBatchOfFetchedObjects:objects
                                         pageNumber:pageNumber];
         else if (error)
             [self processObjectFetchError:error pageNumber:pageNumber];

         if (fun)
             fun(objects, error);
     }];
}

- (void)processNextBatchOfFetchedObjects:(NSArray *)objects
                              pageNumber:(NSInteger)pageNumber
{
    //if (pageNumber == 1 && ![self showsDataBeforeFirstFetch]) {
    //    [self loadDataController];
    //    [[self tableView] reloadData];
    //}

    NSLog(@"Number of objects on page %d: %d", pageNumber, [objects count]);
    NSLog(@"Total number of objects: %d",
          [[[self dataController] fetchedObjects] count]);

    if ([[self lokaliteStream] hasMorePages] && pageNumber == 1)
        [[self tableView] setTableFooterView:[self loadingMoreActivityView]];
    else
        [[self tableView] setTableFooterView:nil];
}

- (void)processObjectFetchError:(NSError *)error
                     pageNumber:(NSInteger)pageNumber
{
}

- (LokaliteStream *)lokaliteStreamInstance
{
    NSAssert2(NO, @"%@: %@ - Must be implemented by subclsases",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return nil;
}

#pragma mark - Account events

- (void)processAccountAddition:(LokaliteAccount *)account
{
    if ([self shouldResetForAccountAddition:account]) {
        [[self lokaliteStream] resetStream];
        [[self lokaliteStream] setEmail:[account email]
                               password:[account password]];
        [self deleteAllStreamObjects];
    }
}

- (void)processAccountDeletion:(LokaliteAccount *)account
{
    if ([self shouldResetForAccountDeletion:account]) {
        [[self lokaliteStream] resetStream];
        [[self lokaliteStream] removeEmailAndPassword];
        [self deleteAllStreamObjects];
    }
}

- (BOOL)shouldResetForAccountAddition:(LokaliteAccount *)account
{
    return NO;
}

- (BOOL)shouldResetForAccountDeletion:(LokaliteAccount *)account
{
    return NO;
}

#pragma mark - Persistence management

- (void)deleteAllStreamObjects
{
    // this operation should probably not be done in this class
    NSManagedObjectContext *context = [self context];
    NSString *entityName = [self lokaliteObjectEntityName];
    Class class = NSClassFromString(entityName);
    NSPredicate *pred = [self dataControllerPredicate];
    NSArray *objects = [class findAllWithPredicate:pred inContext:context];

    [objects enumerateObjectsUsingBlock:
     ^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
         [context deleteObject:obj];
     }];
}

- (void)subscribeForNotificationsForContext:(NSManagedObjectContext *)context
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(managedObjectContextDidChange:)
               name:NSManagedObjectContextObjectsDidChangeNotification
             object:context];
}

- (void)unsubscribeForNotoficationsForContext:(NSManagedObjectContext *)context
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:NSManagedObjectContextObjectsDidChangeNotification
                object:context];
}

- (void)managedObjectContextDidChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];

    NSArray *insertedObjects = [userInfo objectForKey:NSInsertedObjectsKey];
    [insertedObjects enumerateObjectsUsingBlock:
     ^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
         if ([obj isKindOfClass:[LokaliteAccount class]]) {
             LokaliteAccount *account = (LokaliteAccount *) obj;
             [self processAccountAddition:account];
         }
     }];

    NSArray *deletedObjects = [userInfo objectForKey:NSDeletedObjectsKey];
    [deletedObjects enumerateObjectsUsingBlock:
     ^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
         if ([obj isKindOfClass:[LokaliteAccount class]]) {
             LokaliteAccount *account = (LokaliteAccount *) obj;
             [self processAccountDeletion:account];
         }
     }];
}

#pragma mark - Search bar management

- (void)loadSearchBar
{
    UISearchBar *searchBar = [[UISearchBar alloc] init];
    [searchBar setAutocapitalizationType:UITextAutocapitalizationTypeNone];
    [searchBar setAutocorrectionType:UITextAutocorrectionTypeNo];
    UISearchDisplayController *searchDisplayController =
        [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                          contentsController:self];
    [searchBar setDelegate:self];
    [searchBar sizeToFit];
    [[self tableView] setTableHeaderView:searchBar];
    [searchBar release], searchBar = nil;

    [searchDisplayController setDelegate:self];
    [searchDisplayController setSearchResultsDataSource:self];
    [searchDisplayController setSearchResultsDelegate:self];
}

- (void)unloadSearchBar
{
    [[self tableView] setTableHeaderView:nil];
}

#pragma mark - Category filter management

- (void)loadCategoryFilter
{
    [self setLoadedCategoryFilters:[self categoryFilters]];

    if ([self isViewLoaded]) {
        NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray *paths = [NSArray arrayWithObject:first];
        [[self tableView] insertRowsAtIndexPaths:paths
                                withRowAnimation:UITableViewRowAnimationBottom];
    }
}

- (void)unloadCategoryFilter
{
    [self setLoadedCategoryFilters:nil];

    if ([self isViewLoaded]) {
        NSIndexPath *first = [NSIndexPath indexPathForRow:0 inSection:0];
        NSArray *paths = [NSArray arrayWithObject:first];
        [[self tableView] deleteRowsAtIndexPaths:paths
                                withRowAnimation:UITableViewRowAnimationTop];
    }
}

#pragma mark - Application notifications

- (void)subscribeForApplicationLifecycleNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self
           selector:@selector(applicationWillEnterForeground:)
               name:UIApplicationWillEnterForegroundNotification
             object:[UIApplication sharedApplication]];
    [nc addObserver:self
           selector:@selector(applicationDidEnterBackground:)
               name:UIApplicationDidEnterBackgroundNotification
             object:[UIApplication sharedApplication]];
}

- (void)unsubscribeForApplicationLifecycleNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc removeObserver:self
                  name:UIApplicationWillEnterForegroundNotification
                object:[UIApplication sharedApplication]];
    [nc removeObserver:self
                  name:UIApplicationDidEnterBackgroundNotification
                object:[UIApplication sharedApplication]];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self refresh:self];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
}

#pragma mark - Accessors

- (void)setShowsSearchBar:(BOOL)showsSearchBar
{
    if (showsSearchBar_ != showsSearchBar) {
        showsSearchBar_ = showsSearchBar;

        if (showsSearchBar)
            [self loadSearchBar];
        else
            [self unloadSearchBar];
    }
}

- (void)setShowsCategoryFilter:(BOOL)showsCategoryFilter
{
    if (showsCategoryFilter_ != showsCategoryFilter) {
        showsCategoryFilter_ = showsCategoryFilter;

        if (showsCategoryFilter)
            [self loadCategoryFilter];
        else
            [self unloadCategoryFilter];
    }
}

- (CategoryFilterView *)categoryFilterView
{
    if (!categoryFilterView_) {
        CGRect frame = CGRectMake(0, 0, 320, 80);
        categoryFilterView_ = [[CategoryFilterView alloc] initWithFrame:frame];
    }

    return categoryFilterView_;
}

- (UITableViewCell *)categoryFilterCell
{
    if (!categoryFilterCell_) {
        categoryFilterCell_ =
            [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                   reuseIdentifier:@"CategoryFilterCell"];
        [categoryFilterCell_ addSubview:[self categoryFilterView]];
    }

    return categoryFilterCell_;
}

- (UIView *)loadingMoreActivityView
{
    if (!loadingMoreActivityView_) {
        UIActivityIndicatorView *activityIndicator =
            [[UIActivityIndicatorView alloc]
             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [activityIndicator startAnimating];

        CGRect viewFrame = CGRectMake(0, 0, 320, 60);
        UIView *view = [[UIView alloc] initWithFrame:viewFrame];

        CGRect activityIndicatorFrame = [activityIndicator frame];
        activityIndicatorFrame.origin.x =
            round((viewFrame.size.width - activityIndicatorFrame.size.width)
                  / 2);
        activityIndicatorFrame.origin.y =
            round((viewFrame.size.height - activityIndicatorFrame.size.height)
                  / 2);
        [activityIndicator setFrame:activityIndicatorFrame];

        [view addSubview:activityIndicator];
        [activityIndicator release], activityIndicator = nil;

        loadingMoreActivityView_ = view;
    }

    return loadingMoreActivityView_;
}

- (UIBarButtonItem *)toggleMapViewButtonItem
{
    if (!toggleMapViewButtonItem_) {
        SEL action = @selector(toggleMapView:);
        toggleMapViewButtonItem_ =
            [[UIBarButtonItem mapViewBarButtonItemWithTarget:self
                                                      action:action] retain];
    }

    return toggleMapViewButtonItem_;
}

- (LokaliteStream *)lokaliteStream
{
    if (!lokaliteStream_) {
        lokaliteStream_ = [[self lokaliteStreamInstance] retain];
        LokaliteAccount *account =
            [LokaliteAccount findFirstInContext:[self context]];
        if (account)
            [lokaliteStream_ setEmail:[account email]
                             password:[account password]];
    }

    return lokaliteStream_;
}

@end
