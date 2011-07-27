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

#import "LokaliteAppDelegate.h"

#import "SDKAdditions.h"

@interface LokaliteStreamViewController ()
@property (nonatomic, assign) BOOL hasFetchedData;

#pragma mark - View initialization

- (void)initializeTableView:(UITableView *)tableView;

#pragma mark - Account events

- (void)processAccountAddition:(LokaliteAccount *)account;
- (void)processAccountDeletion:(LokaliteAccount *)account;

#pragma mark - Persistence management

- (void)managedObjectContextDidChange:(NSNotification *)notification;
- (void)subscribeForNotificationsForContext:(NSManagedObjectContext *)context;
- (void)unsubscribeForNotoficationsForContext:(NSManagedObjectContext *)context;

@end


@implementation LokaliteStreamViewController

@synthesize context = context_;
@synthesize dataController = dataController_;

@synthesize lokaliteStream = lokaliteStream_;
@synthesize hasFetchedData = hasFetchedData_;

#pragma mark - Memory management

- (void)dealloc
{
    [context_ release];
    [dataController_ release];
    [lokaliteStream_ release];
    [super dealloc];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self setHasFetchedData:NO];

    [self initializeTableView:[self tableView]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    if ([self hasFetchedData] == NO)
        [self displayActivityViewWithCompletion:^{
            [self fetchNextSetOfObjectsWithCompletion:
             ^(NSArray * objects, NSError *error) {
                 [self hideActivityView];
            }];
        }];
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
        nrows = 0; //[[self searchResults] count];

    return nrows;

}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [self reuseIdentifierForIndexPath:indexPath
                                                      inTableView:tableView];
    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (cell == nil)
        cell = [self tableViewCellInstanceForTableView:tableView
                                       reuseIdentifier:reuseIdentifier];

    NSManagedObject *obj = [[self dataController] objectAtIndexPath:indexPath];
    [self configureCell:cell forObject:obj];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSManagedObject *obj = [[self dataController] objectAtIndexPath:indexPath];
    [self displayDetailsForObject:obj];
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
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
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

#pragma mark - Displaying the activity view

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

#pragma mark - View initialization

- (void)initializeTableView:(UITableView *)tableView
{
    [tableView setRowHeight:[self cellHeightForTableView:tableView]];
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

- (CGFloat)cellHeightForTableView:(UITableView *)tableView
{
    return 44;
}

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

- (void)configureCell:(UITableViewCell *)cell forObject:(NSManagedObject *)obj
{
    NSAssert2(NO, @"%@: %@ - Must be implemented by subclsases",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd));
}

- (void)displayDetailsForObject:(NSManagedObject *)object
{
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

#pragma mark Fetching data from the network

- (void)fetchNextSetOfObjectsWithCompletion:(void (^)(NSArray *, NSError *))fun
{
    [[self lokaliteStream] fetchNextBatchWithResponseHandler:
     ^(NSArray *objects, NSError *error) {
         if (objects) {
             [self processNextBatchOfFetchedObjects:objects];
             [self setHasFetchedData:YES];
         } else if (error)
             [self processObjectFetchError:error];

         if (fun)
             fun(objects, error);
     }];
}

- (void)processNextBatchOfFetchedObjects:(NSArray *)objects
{
}

- (void)processObjectFetchError:(NSError *)error
{
}

- (LokaliteStream *)lokaliteStreamInstance
{
    NSAssert2(NO, @"%@: %@ - Must be implemented by subclsases",
              NSStringFromClass([self class]), NSStringFromSelector(_cmd));
    return nil;
}

#pragma mark - Persistence management

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

#pragma mark - Handling account events

- (void)processAccountAddition:(LokaliteAccount *)account
{
    if ([self shouldResetDataForAccountAddition:account]) {
        // this operation should probably not be done in this class
        NSString *entityName = [self lokaliteObjectEntityName];
        Class class = NSClassFromString(entityName);
        [class deleteAllInContext:[self context]];
    }
}

- (void)processAccountDeletion:(LokaliteAccount *)account
{
}

- (BOOL)shouldResetDataForAccountAddition:(LokaliteAccount *)account
{
    return NO;
}

#pragma mark - Accessors

- (LokaliteStream *)lokaliteStream
{
    if (!lokaliteStream_)
        lokaliteStream_ = [[self lokaliteStreamInstance] retain];

    return lokaliteStream_;
}

- (NSFetchedResultsController *)dataController
{
    if (!dataController_)
        dataController_ = [[self configuredFetchedResultsController] retain];

    return dataController_;
}

@end
