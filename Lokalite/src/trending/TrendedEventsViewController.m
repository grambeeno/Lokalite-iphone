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

#import "SDKAdditions.h"

@interface TrendedEventsViewController ()

@property (nonatomic, retain) NSFetchedResultsController *dataController;

#pragma mark - View initialization

- (void)initializeTableView:(UITableView *)tableView;

#pragma mark - View configuration

- (void)configureCell:(EventTableViewCell *)cell forEvent:(Event *)event;

@end


@implementation TrendedEventsViewController

@synthesize context = context_;
@synthesize dataController = dataController_;

#pragma mark - Memory management

- (void)dealloc
{
    [context_ release];
    [dataController_ release];

    [super dealloc];
}

#pragma mark - UITableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeTableView:[self tableView]];
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [[[self dataController] sections] count];
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
            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]
                       withRowAnimation:UITableViewRowAnimationFade];
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
}

#pragma mark - View initialization

- (void)initializeTableView:(UITableView *)tableView
{
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [tableView setRowHeight:[EventTableViewCell cellHeight]];
}

#pragma mark - View configuration

- (void)configureCell:(EventTableViewCell *)cell forEvent:(Event *)event
{
    [cell configureCellForEvent:event displayDistance:NO];
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

        NSPredicate *pred =
            [NSPredicate predicateWithFormat:@"trended == YES"];
        NSArray *sortDescriptors = [Event dateTableViewSortDescriptors];

        NSFetchRequest *req = [[NSFetchRequest alloc] init];
        [req setEntity:entity];
        [req setPredicate:pred];
        [req setSortDescriptors:sortDescriptors];

        NSFetchedResultsController *controller =
            [[NSFetchedResultsController alloc] initWithFetchRequest:req
                                                managedObjectContext:context
                                                  sectionNameKeyPath:nil
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

@end
