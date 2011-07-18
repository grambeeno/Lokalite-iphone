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

@interface EventsViewController ()

@property (nonatomic, retain) LokaliteEventStream *stream;

@property (nonatomic, copy) NSArray *events;

#pragma mark - View initialization

- (void)initializeTableView;

#pragma mark - Fetching data

- (void)fetchNextSetOfEvents;

@end

@implementation EventsViewController

@synthesize context = context_;

@synthesize stream = stream_;

@synthesize events = events_;

#pragma mark - Memory management

- (void)dealloc
{
    [context_ release];

    [stream_ release];

    [events_ release];

    [super dealloc];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self initializeTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([[self events] count] == 0)
        [self fetchNextSetOfEvents];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    return io == UIInterfaceOrientationPortrait;
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[self events] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell =
            [[[UITableViewCell alloc]
              initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:CellIdentifier] autorelease];
    }

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - View initialization

- (void)initializeTableView
{
    [[self tableView] setRowHeight:[EventTableViewCell cellHeight]];
}

#pragma mark - Fetching data

- (void)fetchNextSetOfEvents
{
    [[self stream] fetchNextBatchWithResponseHandler:
     ^(NSArray *events, NSError *error) {
         NSLog(@"Fetched %d events.", [events count]);
     }];
}

#pragma mark - Accessors

- (LokaliteEventStream *)stream
{
    if (!stream_) {
        stream_ = [LokaliteEventStream streamWithContext:[self context]];
    }

    return stream_;
}

@end
