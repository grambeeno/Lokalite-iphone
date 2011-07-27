//
//  LokaliteStreamViewController.h
//  Lokalite
//
//  Created by John Debay on 7/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@class LokaliteAccount, LokaliteStream;

@interface LokaliteStreamViewController : UITableViewController
    <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) LokaliteStream *lokaliteStream;

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *dataController;

@property (nonatomic, assign) NSInteger pagesFetched;


#pragma mark - Displaying the activity view

- (void)displayActivityView;
- (void)displayActivityViewWithCompletion:(void (^)(void))completion;
- (void)hideActivityView;
- (void)hideActivityViewWithCompletion:(void (^)(void))completion;




#pragma mark - Protected interface


#pragma mark Configuring the view

- (NSString *)titleForView;


#pragma mark Configuring the table view

- (CGFloat)cellHeightForTableView:(UITableView *)tableView;
- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView;
- (UITableViewCell *)tableViewCellInstanceForTableView:(UITableView *)tableView
                                       reuseIdentifier:(NSString *)identifier;

- (void)configureCell:(UITableViewCell *)cell
            forObject:(NSManagedObject *)object;

- (void)displayDetailsForObject:(NSManagedObject *)object;


#pragma mark Working with the local data store

//
// Override to configure the results controller yourself. Optionally you can
// override one or more of the methods below to provide the desired
// customization.
//
- (NSFetchedResultsController *)configuredFetchedResultsController;

- (NSString *)lokaliteObjectEntityName;
- (NSPredicate *)dataControllerPredicate;
- (NSArray *)dataControllerSortDescriptors;

- (NSString *)dataControllerSectionNameKeyPath;
- (NSString *)dataControllerCacheName;

#pragma mark - Account events

- (BOOL)shouldResetDataForAccountAddition:(LokaliteAccount *)account;
- (BOOL)shouldResetDataForAccountDeletion:(LokaliteAccount *)account;

#pragma mark Fetching data from the network

- (void)fetchNextSetOfObjectsWithCompletion:(void (^)(NSArray *, NSError *))fun;

- (void)processNextBatchOfFetchedObjects:(NSArray *)objects
                              pageNumber:(NSInteger)pageNumber;
- (void)processObjectFetchError:(NSError *)error
                     pageNumber:(NSInteger)pageNumber;

- (LokaliteStream *)lokaliteStreamInstance;

@end
