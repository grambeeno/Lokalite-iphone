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

#import <CoreData/CoreData.h>

@interface FeaturedViewController ()

@property (nonatomic, assign) BOOL shouldFetchedData;
@property (nonatomic, retain) LokaliteFeaturedEventStream *stream;

@property (nonatomic, copy) NSArray *otherEvents;

#pragma mark - View initialization

- (void)initializeNavigationItem;
- (void)initializeTableView;
- (void)initializeData;

#pragma mark - View configuration

- (void)configureCell:(EventTableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)path;

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

@synthesize shouldFetchedData = shouldFetchedData_;
@synthesize stream = stream_;

@synthesize otherEvents = otherEvents_;

#pragma mark - Memory management

- (void)dealloc
{
    [self unsubscribeForApplicationLifecycleNotifications];

    [context_ release];

    [headerView_ release];

    [stream_ release];

    [otherEvents_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        shouldFetchedData_ = YES;

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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[self otherEvents] count];
}

- (CGFloat)tableView:(UITableView *)tableView
    heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [EventTableViewCell cellHeight];
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

    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [[self otherEvents] objectAtIndex:[indexPath row]];
    EventDetailsViewController *controller =
        [[EventDetailsViewController alloc] initWithEvent:event];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
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
}

- (void)initializeData
{
    NSArray *events = [Event findAllInContext:[self context]];
    [self processReceivedEvents:events];
}

#pragma mark - View configuration

- (void)configureCell:(EventTableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)path
{
    Event *event = [[self otherEvents] objectAtIndex:[path row]];
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
        BOOL showActivityView = [[self otherEvents] count] == 0;
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
    NSURL *baseUrl = [[self stream] baseUrl];
    NSString *urlPath = [event imageUrl];
    NSURL *url = [baseUrl URLByAppendingPathComponent:urlPath];

    UITableView *tableView = [self tableView];
    NSArray *events = [self otherEvents];
    [DataFetcher fetchDataAtUrl:url responseHandler:
     ^(NSData *data, NSError *error) {
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

- (void)processReceivedEvents:(NSArray *)events
{
    UITableView *tableView = [self tableView];
    NSIndexSet *sections = nil;

    if ([self isViewLoaded]) {
        [tableView beginUpdates];
        sections = [NSIndexSet indexSetWithIndex:0];
        [tableView deleteSections:sections
                 withRowAnimation:UITableViewRowAnimationTop];
    }

    [self setOtherEvents:events];

    if ([self isViewLoaded]) {
        [tableView insertSections:sections
                 withRowAnimation:UITableViewRowAnimationBottom];
        [tableView endUpdates];
    }
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
        NSString *baseUrlString =
            [[NSBundle mainBundle]
             objectForInfoDictionaryKey:@"LokaliteAPIServer"];
        NSURL *baseUrl = [NSURL URLWithString:baseUrlString];
        NSManagedObjectContext *moc = [self context];
        stream_ = [[LokaliteFeaturedEventStream alloc] initWithBaseUrl:baseUrl
                                                               context:moc];
    }

    return stream_;
}

@end
