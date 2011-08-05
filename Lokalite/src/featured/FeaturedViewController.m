//
//  NewFeaturedViewController.m
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "FeaturedViewController.h"

#import "LokaliteFeaturedEventStream.h"

#import "Event.h"
#import "EventTableViewCell.h"

#import "EventDetailsViewController.h"

#import "LokaliteAppDelegate.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface FeaturedViewController ()

@property (nonatomic, retain) NSFetchedResultsController *resultsController;

@property (nonatomic, assign) BOOL shouldFetchedData;
@property (nonatomic, retain) LokaliteFeaturedEventStream *stream;

//@property (nonatomic, copy) NSArray *otherEvents;

#pragma mark - View initialization

- (void)initializeNavigationItem;
- (void)initializeTableView;
- (void)initializeData;

#pragma mark - View configuration

- (void)configureCell:(EventTableViewCell *)cell
          atIndexPath:(NSIndexPath *)path;
- (void)configureCell:(EventTableViewCell *)cell forEvent:(Event *)event;

#pragma mark - Fetch data

- (void)fetchFeaturedEventsIfNecessary;
- (void)fetchImageForEvent:(Event *)event;

#pragma mark - Processing data

- (void)processReceivedEvents:(NSArray *)events;
- (void)processReceivedError:(NSError *)error;

#pragma mark - Application notifications

- (void)subscribeForApplicationLifecycleNotifications;
- (void)unsubscribeForApplicationLifecycleNotifications;

@end

@implementation FeaturedViewController

@synthesize context = context_;

@synthesize headerView = headerView_;

@synthesize resultsController = resultsController_;

@synthesize shouldFetchedData = shouldFetchedData_;
@synthesize stream = stream_;

//@synthesize otherEvents = otherEvents_;

#pragma mark - Memory management

- (void)dealloc
{
    [self unsubscribeForApplicationLifecycleNotifications];

    [context_ release];

    [headerView_ release];

    [resultsController_ release];

    [stream_ release];

    //[otherEvents_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        shouldFetchedData_ = YES;
        [self setTitle:NSLocalizedString(@"global.featured", nil)];
    }

    return self;
}

#pragma mark - UI events

- (void)refresh:(id)sender
{
    [self setShouldFetchedData:YES];
    [self fetchFeaturedEventsIfNecessary];
}

- (void)toggleMapView:(id)sender
{
}

#pragma mark - UITableViewController implementation

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    NSLog(@"%@: %@", NSStringFromClass([self class]),
          NSStringFromSelector(_cmd));
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self subscribeForApplicationLifecycleNotifications];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];
    [self initializeTableView];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    return io == UIInterfaceOrientationPortrait;
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self resultsController] sections] count];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo =
        [[[self resultsController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = nil;
    if (!CellIdentifier)
        CellIdentifier = [[EventTableViewCell defaultReuseIdentifier] copy];

    EventTableViewCell *cell = (EventTableViewCell *)
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [EventTableViewCell instanceFromNib];

    [self configureCell:cell atIndexPath:indexPath];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [[self resultsController] objectAtIndexPath:indexPath];
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

    switch(type) {
        case NSFetchedResultsChangeInsert:
            [tableView
             insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                   withRowAnimation:UITableViewRowAnimationBottom];
            break;

        case NSFetchedResultsChangeDelete:
            [tableView
             deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                   withRowAnimation:UITableViewRowAnimationTop];
            break;

        case NSFetchedResultsChangeUpdate: {
                EventTableViewCell *cell = (EventTableViewCell *)
                    [tableView cellForRowAtIndexPath:indexPath];
                // HACK: The data controller cannot be accessed with the
                // provided index path; doing so causes a crash. I don't know
                // why. Accessing the cell via the provided anObject parameter
                // works fine, though.
                [self configureCell:cell forEvent:anObject];
            }
            break;

        case NSFetchedResultsChangeMove:
            NSLog(@"Moving event from index path: %@ to index path: %@",
                  indexPath, newIndexPath);
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

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    UIBarButtonItem *refreshButtonItem =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh
                              target:self
                              action:@selector(refresh:)];
    [[self navigationItem] setLeftBarButtonItem:refreshButtonItem];
    [refreshButtonItem release], refreshButtonItem = nil;

    UIImage *mapImage = [UIImage imageNamed:@"radar"];
    UIBarButtonItem *mapButtonItem =
        [[UIBarButtonItem alloc] initWithImage:mapImage
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(toggleMapView:)];
    [[self navigationItem] setRightBarButtonItem:mapButtonItem];
    [mapButtonItem release], mapButtonItem = nil;
}

- (void)initializeTableView
{
    //[[self tableView] setTableHeaderView:[self headerView]];
    [[self tableView] setRowHeight:[EventTableViewCell cellHeight]];
}

- (void)initializeData
{
    NSArray *events = [Event findAllInContext:[self context]];
    [self processReceivedEvents:events];
}

#pragma mark - View configuration

- (void)configureCell:(EventTableViewCell *)cell
          atIndexPath:(NSIndexPath *)path
{
    Event *event = [[self resultsController] objectAtIndexPath:path];
    [self configureCell:cell forEvent:event];
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

#pragma mark - Fetch data

- (void)fetchFeaturedEventsIfNecessary
{
    if ([self shouldFetchedData]) {
        BOOL showActivityView =
            [[[self resultsController] fetchedObjects] count] == 0;
        LokaliteAppDelegate *appDelegate = (LokaliteAppDelegate *)
            [[UIApplication sharedApplication] delegate];

        void (^fetchObjects)(LokaliteStream *) = ^(LokaliteStream *stream) {
            [stream fetchNextBatchOfObjectsWithResponseHandler:
             ^(NSArray *events, NSError *error) {
                 if (events) {
                     NSLog(@"Fetched %d events", [events count]);
                     [self processReceivedEvents:events];
                     [self setShouldFetchedData:NO];
                 } else
                     [self processReceivedError:error];

                 if (showActivityView)
                     [appDelegate hideActivityViewAnimated:YES];
             }];
        };

        LokaliteStream *stream = [self stream];
        if (showActivityView)
            [appDelegate
             displayActivityViewAnimated:YES
                              completion:^{ fetchObjects(stream); }];
        else
            fetchObjects(stream);
    }
}

- (void)fetchImageForEvent:(Event *)event
{
    [[UIApplication sharedApplication] networkActivityIsStarting];

    NSURL *baseUrl = [[self stream] baseUrl];
    NSString *urlPath = [event imageUrl];
    NSURL *url = [baseUrl URLByAppendingPathComponent:urlPath];

    UITableView *tableView = [self tableView];
    NSArray *events = [[self resultsController] fetchedObjects];
    [DataFetcher fetchDataAtUrl:url responseHandler:
     ^(NSData *data, NSError *error) {
         [[UIApplication sharedApplication] networkActivityDidFinish];

         if (data) {
             __block UIImage *image = nil;
             NSArray *visibleCells = [tableView visibleCells];
             [visibleCells enumerateObjectsUsingBlock:
              ^(EventTableViewCell *cell, NSUInteger idx, BOOL *stop) {
                  NSIndexPath *path = [tableView indexPathForCell:cell];
                  Event *e = [events objectAtIndex:[path row]];
                  if ([[e imageUrl] isEqualToString:urlPath]) {
                      if (!image)
                          image = [UIImage imageWithData:data];
                      [[cell eventImageView] setImage:image];
                      [e setImageData:data];
                  }
             }];
         } else
             NSLog(@"WARNING: Failed to download image data for event: %@: %@",
                   [event identifier], [error detailedDescription]);
    }];
}

#pragma mark - Processing data

#import "LokaliteObjectBuilder.h"

- (void)processReceivedEvents:(NSArray *)events
{
    NSManagedObjectContext *context = [self context];
    NSArray *allEvents = [Event findAllInContext:context];

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

#pragma mark - Application notifications

- (void)applicationDidFinishLaunching:(NSNotification *)notification
{
    [self initializeData];
    [self fetchFeaturedEventsIfNecessary];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self fetchFeaturedEventsIfNecessary];
}

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    [self setShouldFetchedData:YES];
}

- (void)subscribeForApplicationLifecycleNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

    [nc addObserver:self
           selector:@selector(applicationDidFinishLaunching:)
               name:UIApplicationDidFinishLaunchingNotification
             object:[UIApplication sharedApplication]];
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
                  name:UIApplicationDidFinishLaunchingNotification
                object:[UIApplication sharedApplication]];
    [nc removeObserver:self
                  name:UIApplicationWillEnterForegroundNotification
                object:[UIApplication sharedApplication]];
    [nc removeObserver:self
                  name:UIApplicationDidEnterBackgroundNotification
                object:[UIApplication sharedApplication]];
}

#pragma mark - Accessors

- (LokaliteStream *)stream
{
    if (!stream_) {
        NSManagedObjectContext *moc = [self context];
        stream_ = [[LokaliteFeaturedEventStream streamWithContext:moc] retain];
        //stream_ = [[LokaliteFeaturedEventStream alloc] initWithBaseUrl:baseUrl
        //                                                       context:moc];
    }

    return stream_;
}

- (NSFetchedResultsController *)resultsController
{
    if (!resultsController_) {
        NSManagedObjectContext *context = [self context];
        NSString *entityName = NSStringFromClass([Event class]);
        NSEntityDescription *entity =
            [NSEntityDescription entityForName:entityName
                        inManagedObjectContext:context];

        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        [req setEntity:entity];

        NSPredicate *predicate =
            [NSPredicate predicateWithFormat:@"featured == YES"];
        [req setPredicate:predicate];

        NSSortDescriptor *sd1 =
            [[NSSortDescriptor alloc] initWithKey:@"endDate" ascending:YES];
        NSSortDescriptor *sd2 =
            [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
        NSArray *sds = [[NSArray alloc] initWithObjects:sd1, sd2, nil];
        [req setSortDescriptors:sds];
        [sds release], sds = nil;
        [sd1 release], sd1 = nil;
        [sd2 release], sd2 = nil;

        NSFetchedResultsController *controller =
            [[NSFetchedResultsController alloc] initWithFetchRequest:req
                                                managedObjectContext:context
                                                  sectionNameKeyPath:nil
                                                           cacheName:nil];
        [req release], req = nil;

        NSError *error = nil;
        if ([controller performFetch:&error]) {
            resultsController_ = controller;
            [resultsController_ setDelegate:self];
        } else {
            NSLog(@"Failed to initialize fetched results controller: %@",
                  [error detailedDescription]);
            [controller release], controller = nil;
        }
    }

    return resultsController_;
}

@end
