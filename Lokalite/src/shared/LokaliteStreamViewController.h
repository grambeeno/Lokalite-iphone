//
//  LokaliteStreamViewController.h
//  Lokalite
//
//  Created by John Debay on 7/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "MapDisplayController.h"

#import <MapKit/MapKit.h>

@protocol LokaliteObject;
@class LokaliteAccount, LokaliteStream;

@interface LokaliteStreamViewController : UITableViewController
    <NSFetchedResultsControllerDelegate, MapDisplayControllerDelegate>

#pragma mark - Fetching data

@property (nonatomic, retain) LokaliteStream *lokaliteStream;
@property (nonatomic, assign) BOOL showsDataBeforeFirstFetch;

#pragma mark - View configuration

//@property (nonatomic, assign) BOOL showsSearchBar;

#pragma mark - Map view

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain)
    IBOutlet MapDisplayController *mapViewController;
@property (nonatomic, retain, readonly)
    UIBarButtonItem *toggleMapViewButtonItem;

#pragma mark - Data store

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *dataController;

@property (nonatomic, assign) NSInteger pagesFetched;

#pragma mark - Button actions

- (void)refresh:(id)sender;


#pragma mark - Displaying the activity view

- (void)displayActivityView;
- (void)displayActivityViewWithCompletion:(void (^)(void))completion;
- (void)hideActivityView;
- (void)hideActivityViewWithCompletion:(void (^)(void))completion;




//
// Protected interface - do not call these methods directly
//

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

- (void)displayDetailsForObject:(id<LokaliteObject>)object;


#pragma mark Working with the map view

- (void)presentMapViewAnimated:(BOOL)animated;
- (void)dismissMapViewAnimated:(BOOL)animated;
- (void)toggleMapViewAnimated:(BOOL)animated;


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

#pragma mark Account events

- (BOOL)shouldResetForAccountAddition:(LokaliteAccount *)account;
- (BOOL)shouldResetForAccountDeletion:(LokaliteAccount *)account;

#pragma mark Fetching data from the network

- (void)fetchNextSetOfObjectsWithCompletion:(void (^)(NSArray *, NSError *))fun;

- (void)processNextBatchOfFetchedObjects:(NSArray *)objects
                              pageNumber:(NSInteger)pageNumber;
- (void)processObjectFetchError:(NSError *)error
                     pageNumber:(NSInteger)pageNumber;

- (LokaliteStream *)lokaliteStreamInstance;

@end
