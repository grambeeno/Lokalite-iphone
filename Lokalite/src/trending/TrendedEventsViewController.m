//
//  TrendedEventsViewController.m
//  Lokalite
//
//  Created by John Debay on 8/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TrendedEventsViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"
#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"

#import "NoDataView.h"

#import "SDKAdditions.h"

@interface TrendedEventsViewController ()

@property (nonatomic, retain) NSFetchedResultsController *dataController;
@property (nonatomic, retain) NoDataView *noDataView;

#pragma mark - View initialization

- (void)initializeNavigationItem:(UINavigationItem *)navigationItem;
- (void)initializeTableView:(UITableView *)tableView;

#pragma mark - View configuration

- (void)configureCell:(EventTableViewCell *)cell forEvent:(Event *)event;

- (void)presentNoDataView;
- (void)dismissNoDataView;

@end


@implementation TrendedEventsViewController

@synthesize context = context_;
@synthesize settingsButtonItem = settingsButtonItem_;
@synthesize timeSelector = timeSelector_;
@synthesize dataController = dataController_;
@synthesize noDataView = noDataView_;

#pragma mark - Memory management

- (void)dealloc
{
    [context_ release];
    [settingsButtonItem_ release];
    [timeSelector_ release];
    [dataController_ release];
    [noDataView_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
        [self setTitle:NSLocalizedString(@"trended-events.title", nil)];

    return self;
}

#pragma mark - UI events

- (IBAction)timeSelectorValueChanged:(id)sender
{
    [self setDataController:nil];
    [[self tableView] reloadData];

    if ([[[self dataController] sections] count] == 0)
        [self presentNoDataView];
    else
        [self dismissNoDataView];
}

- (IBAction)presentSettings:(id)sender
{
    SettingsViewController *controller =
        [[SettingsViewController alloc] initWithContext:[self context]];
    [controller setDelegate:self];

    UINavigationController *nc =
        [[UINavigationController alloc] initWithRootViewController:controller];
    [[nc navigationBar] setTintColor:
     [[[self navigationController] navigationBar] tintColor]];

    [self presentModalViewController:nc animated:YES];

    [nc release], nc = nil;
    [controller release], controller = nil;
}

#pragma mark - UITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem:[self navigationItem]];
    [self initializeTableView:[self tableView]];

    if ([[[self dataController] fetchedObjects] count] == 0)
        [self presentNoDataView];
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self dataController] sections] count];
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    return [[[[self dataController] sections] objectAtIndex:section] name];
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    id <NSFetchedResultsSectionInfo> sectionInfo =
        [[[self dataController] sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = [EventTableViewCell defaultReuseIdentifier];

    EventTableViewCell *cell = (EventTableViewCell *)
        [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil)
        cell = [EventTableViewCell instanceFromNib];

    Event *event = [[self dataController] objectAtIndexPath:indexPath];
    [self configureCell:cell forEvent:event];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [[self dataController] objectAtIndexPath:indexPath];
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
  didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex
     forChangeType:(NSFetchedResultsChangeType)type
{
    NSIndexSet *sections = [NSIndexSet indexSetWithIndex:sectionIndex];
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [[self tableView] insertSections:sections
                            withRowAnimation:UITableViewRowAnimationBottom];
            break;
 
        case NSFetchedResultsChangeDelete:
            [[self tableView] deleteSections:sections
                            withRowAnimation:UITableViewRowAnimationTop];
            break;
    }
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
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
            [self dismissNoDataView];
            break;
 
        case NSFetchedResultsChangeDelete:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
            break;

        case NSFetchedResultsChangeUpdate: {
            EventTableViewCell *eventCell = (EventTableViewCell *)
                [tableView cellForRowAtIndexPath:indexPath];
            [self configureCell:eventCell forEvent:anObject];
        }
            break;
 
        case NSFetchedResultsChangeMove:
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
    [[self tableView] endUpdates];

    if ([[[self dataController] fetchedObjects] count] == 0)
        [self presentNoDataView];
}

#pragma mark - SettingsViewControllerDelegate implementation

- (void)settingsViewControllerIsDone:(SettingsViewController *)controller
{
    [self dismissModalViewControllerAnimated:YES];
}

#pragma mark - View initialization

- (void)initializeNavigationItem:(UINavigationItem *)navigationItem
{
    /*
    UIBarButtonItem *settingsButton =
        [[UIBarButtonItem alloc]
         initWithTitle:@"Settings"
                 style:UIBarButtonItemStyleBordered
                target:self
                action:@selector(presentSettings:)];
    [navigationItem setRightBarButtonItem:settingsButton];
    [settingsButton release], settingsButton = nil;
     */

    [navigationItem setRightBarButtonItem:[self settingsButtonItem]];
}

- (void)initializeTableView:(UITableView *)tableView
{
    [tableView setBackgroundColor:[UIColor tableViewBackgroundColor]];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setRowHeight:[EventTableViewCell cellHeight]];
}

#pragma mark - View configuration

- (void)configureCell:(EventTableViewCell *)cell forEvent:(Event *)event
{
    [cell configureCellForEvent:event displayDistance:NO];
}

- (void)presentNoDataView
{
    NoDataView *noDataView = [self noDataView];
    NSInteger idx = [[self timeSelector] selectedSegmentIndex];

    NSString *title = nil, *description = nil;
    if (idx == 1) {
        title = NSLocalizedString(@"trended-events.history.no-data.title", nil);
        description =
            NSLocalizedString(@"trended-events.history.no-data.description",
                              nil);
    } else {
        title =
            NSLocalizedString(@"trended-events.upcoming.no-data.title", nil);
        description =
            NSLocalizedString(@"trended-events.upcoming.no-data.description",
                              nil);
    }

    [[noDataView titleLabel] setText:title];
    [[noDataView descriptionLabel] setText:description];

    [[self view] addSubview:[self noDataView]];
}

- (void)dismissNoDataView
{
    [[self noDataView] removeFromSuperview];
    [self setNoDataView:nil];
}

#pragma mark - Accessors

- (NSFetchedResultsController *)dataController
{
    if (!dataController_) {
        NSManagedObjectContext *context = [self context];

        // get the name dynamically so the compiler can notify us if the name
        // of the class changes
        NSString *entityName = NSStringFromClass([Event class]);
        NSEntityDescription *entity =
            [NSEntityDescription entityForName:entityName
                        inManagedObjectContext:context];

        NSInteger selectedIndex = [[self timeSelector] selectedSegmentIndex];
        NSDate *endDate = [NSDate date];
        NSPredicate *pred =
            selectedIndex == 0 ?
            [NSPredicate
             predicateWithFormat:@"trended == YES && endDate >= %@", endDate] :
            [NSPredicate
             predicateWithFormat:@"trended == YES && endDate < %@", endDate];
        NSArray *sortDescriptors = [Event dateTableViewSortDescriptors];

        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        [req setEntity:entity];
        [req setPredicate:pred];
        [req setSortDescriptors:sortDescriptors];

        NSString *sectionKeyPath =
            [[self timeSelector] selectedSegmentIndex] == 0 ?
             @"dateDescription" : nil;

        NSFetchedResultsController *controller =
            [[NSFetchedResultsController alloc]
             initWithFetchRequest:req
             managedObjectContext:context
               sectionNameKeyPath:sectionKeyPath
                        cacheName:nil];
        [req release], req = nil;

        NSError *error = nil;
        if ([controller performFetch:&error]) {
            [controller setDelegate:self];
            dataController_ = controller;
        } else {
            NSLog(@"%@: %@ - WARNING: Failed to initialize fetched results "
                  "controller: %@", NSStringFromClass([self class]),
                  NSStringFromSelector(_cmd), [error detailedDescription]);
            [controller release], controller = nil;
        }
    }

    return dataController_;
}

- (NoDataView *)noDataView
{
    if (!noDataView_)
        noDataView_ = [[NoDataView instanceFromNib] retain];

    return noDataView_;
}

@end
