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

#import "NSManagedObject+GeneralHelpers.h"

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

- (void)configureCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)path;

#pragma mark - Fetch data

- (void)fetchFeaturedEventsIfNecessary;

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
    [self initializeData];
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

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:CellIdentifier] autorelease];

    [self configureCell:cell forRowAtIndexPath:indexPath];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
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
    [[self tableView] setTableHeaderView:[self headerView]];
}

- (void)initializeData
{
    NSArray *events = [Event findAllInContext:[self context]];
    [self processReceivedEvents:events];
}

#pragma mark - View configuration

- (void)configureCell:(UITableViewCell *)cell
    forRowAtIndexPath:(NSIndexPath *)path
{
    Event *event = [[self otherEvents] objectAtIndex:[path row]];
    [[cell textLabel] setText:[event name]];
}

#pragma mark - Fetch data

- (void)fetchFeaturedEventsIfNecessary
{
    if ([self shouldFetchedData]) {
        [[self stream] fetchNextBatchOfObjectsWithResponseHandler:
         ^(NSArray *events, NSError *error) {
             if (events) {
                 NSLog(@"Fetched %d events", [events count]);
                 [self processReceivedEvents:events];
                 [self setShouldFetchedData:NO];
             } else
                 [self processReceivedError:error];
        }];
    }
}

#pragma mark - Processing data

- (void)processReceivedEvents:(NSArray *)events
{
    UITableView *tableView = [self tableView];

    [tableView beginUpdates];
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:0];
    [tableView deleteSections:sections
             withRowAnimation:UITableViewRowAnimationTop];

    [self setOtherEvents:events];

    [tableView insertSections:sections
             withRowAnimation:UITableViewRowAnimationBottom];
    [tableView endUpdates];
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
        stream_ = [[LokaliteFeaturedEventStream alloc] initWithContext:moc];
    }

    return stream_;
}

@end
