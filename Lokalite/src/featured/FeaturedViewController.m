//
//  NewFeaturedViewController.m
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "FeaturedViewController.h"
#import "LokaliteFeaturedEventStream.h"

#import <CoreData/CoreData.h>

@interface FeaturedViewController ()

@property (nonatomic, assign) BOOL hasFetchedData;
@property (nonatomic, retain) LokaliteFeaturedEventStream *stream;

#pragma mark - View initialization

- (void)initializeNavigationItem;
- (void)initializeTableView;

#pragma mark - Fetch data

- (void)fetchFeaturedEventsIfNecessary;

@end

@implementation FeaturedViewController

@synthesize context = context_;

@synthesize headerView = headerView_;

@synthesize hasFetchedData = hasFetchedData_;
@synthesize stream = stream_;

#pragma mark - Memory management

- (void)dealloc
{
    [context_ release];

    [headerView_ release];

    [stream_ release];

    [super dealloc];
}

#pragma mark - UITableViewController implementation

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];

    NSLog(@"%@: %@", NSStringFromClass([self class]),
          NSStringFromSelector(_cmd));
}

#pragma mark - View lifecycle

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

    [self fetchFeaturedEventsIfNecessary];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc]
                 initWithStyle:UITableViewCellStyleDefault
                 reuseIdentifier:CellIdentifier] autorelease];
    }

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

#pragma mark - Fetch data

- (void)fetchFeaturedEventsIfNecessary
{
    if (![self hasFetchedData]) {
        [[self stream] fetchNextBatchOfObjectsWithResponseHandler:
         ^(NSArray *events, NSError *error) {
            NSLog(@"Fetched %d events", [events count]);
             
        }];
    }
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
