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
#import "EventTableViewCell.h"

#import "LokaliteAppDelegate.h"

#import "SDKAdditions.h"

@interface EventsViewController ()

@property (nonatomic, retain) LokaliteEventStream *stream;

@property (nonatomic, retain) NSFetchedResultsController *dataController;
@property (nonatomic, assign) BOOL hasFetchedData;

#pragma mark - View initialization

- (void)initializeTableView;

#pragma mark - View configuration

- (void)configureCell:(EventTableViewCell *)cell
          atIndexPath:(NSIndexPath *)path;

- (void)displayActivityView;
- (void)displayActivityViewWithCompletion:(void (^)(void))completion;
- (void)hideActivityView;
- (void)hideActivityViewWithCompletion:(void (^)(void))completion;

#pragma mark - Fetching data

- (void)fetchNextSetOfEvents;

#pragma mark - Processing received data

- (void)processReceivedError:(NSError *)error;

#pragma mark - Managing the fetched results controller

- (void)loadDataController;

@end

@implementation EventsViewController

@synthesize context = context_;

@synthesize stream = stream_;

@synthesize dataController = dataController_;
@synthesize hasFetchedData = hasFetchedData_;

#pragma mark - Memory management

- (void)dealloc
{
    [context_ release];

    [stream_ release];

    [dataController_ release];

    [super dealloc];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeTableView];
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
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
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
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                       withRowAnimation:UITableViewRowAnimationTop];
            break;
 
        case NSFetchedResultsChangeUpdate: {
            EventTableViewCell *cell = (EventTableViewCell *)
                [tableView cellForRowAtIndexPath:indexPath];
            [self configureCell:cell atIndexPath:indexPath];
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

#pragma mark - View initialization

- (void)initializeTableView
{
    [[self tableView] setRowHeight:[EventTableViewCell cellHeight]];
}

#pragma mark - View configuration

- (void)configureCell:(EventTableViewCell *)cell
          atIndexPath:(NSIndexPath *)path
{
    Event *event = [[self dataController] objectAtIndexPath:path];
    [cell configureCellForEvent:event];
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

- (LokaliteEventStream *)stream
{
    if (!stream_)
        stream_ = [LokaliteEventStream streamWithContext:[self context]];

    return stream_;
}

//- (NSFetchedResultsController *)dataController
//{
//    if (!dataController_) {
//        NSManagedObjectContext *context = [self context];
//        NSFetchRequest *req = [[NSFetchRequest alloc] init];
//
//        NSEntityDescription *entity =
//            [NSEntityDescription entityForName:@"Event"
//                        inManagedObjectContext:context];
//    
//        [req setEntity:entity];
//
//        NSSortDescriptor *sd =
//            [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:YES];
//        NSArray *sds = [NSArray arrayWithObjects:sd, nil];
//        [req setSortDescriptors:sds];
//
//        NSFetchedResultsController *controller =
//            [[NSFetchedResultsController alloc] initWithFetchRequest:req
//                                                managedObjectContext:context
//                                                  sectionNameKeyPath:nil
//                                                           cacheName:nil];
//        NSError *error = nil;
//        if ([controller performFetch:&error]) {
//            dataController_ = controller;
//            [dataController_ setDelegate:self];
//        } else {
//            [controller release], controller = nil;
//            NSLog(@"Failed to fetch event objects: %@",
//                  [error detailedDescription]);
//        }
//    }
//
//    return dataController_;
//}

@end
