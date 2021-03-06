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

@protocol MappableLokaliteObject;
@class LokaliteAccount, LokaliteStream;
@class CategoryFilter;

@interface LokaliteStreamViewController : UITableViewController
    <NSFetchedResultsControllerDelegate, MapDisplayControllerDelegate,
     UISearchBarDelegate, UISearchDisplayDelegate>

#pragma mark - Fetching data

@property (nonatomic, retain) LokaliteStream *lokaliteStream;
//@property (nonatomic, assign) BOOL showsDataBeforeFirstFetch;

#pragma mark - View configuration

@property (nonatomic, assign) BOOL showsSearchBar;
@property (nonatomic, assign) BOOL showsCategoryFilter;

#pragma mark - Map view

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain)
    IBOutlet MapDisplayController *mapViewController;
@property (nonatomic, retain, readonly) UIBarButtonItem *mapViewButtonItem;

#pragma mark - Refreshing data

@property (nonatomic, retain, readonly) UIBarButtonItem *refreshButtonItem;

- (void)refresh:(id)sender;

#pragma mark - Data store

@property (nonatomic, retain) NSManagedObjectContext *context;
@property (nonatomic, retain) NSFetchedResultsController *dataController;

#pragma mark - Displaying the activity view

/*
- (void)displayActivityView;
- (void)displayActivityViewWithCompletion:(void (^)(void))completion;
- (void)hideActivityView;
- (void)hideActivityViewWithCompletion:(void (^)(void))completion;
 */




//
// Protected interface - do not call these methods directly
//

#pragma mark - Protected interface


#pragma mark Configuring the view

- (NSString *)titleForView;


#pragma mark Configuring the table view

- (void)initializeTableView:(UITableView *)tableView;

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView;
- (UITableViewCell *)tableViewCellInstanceAtIndexPath:(NSIndexPath *)indexPath
                                         forTableView:(UITableView *)tableView
                                      reuseIdentifier:(NSString *)identifier;

- (void)configureCell:(UITableViewCell *)cell
          inTableView:(UITableView *)tableView
            forObject:(id<MappableLokaliteObject>)obj;

- (void)displayDetailsForObject:(id<MappableLokaliteObject>)object;
- (void)displayDetailsForObjectGroup:(NSArray *)group;


#pragma mark - Search - general

@property (nonatomic, copy, readonly) NSArray *searchResults;

#pragma mark Searching - local

- (NSPredicate *)predicateForQueryString:(NSString *)queryString;

#pragma mark Searching - remote

@property (nonatomic, assign) BOOL canSearchServer;

- (LokaliteStream *)remoteSearchLokaliteStreamInstanceForKeywords:
    (NSString *)keywords;

- (NSString *)placeholderTextForRemoteSearchBar;
- (NSString *)titleForRemoteSearchFooterView;

#pragma mark Location

@property (nonatomic, assign) BOOL requiresLocation;
- (BOOL)hasValidLocation;

#pragma mark Working with the map view

- (void)presentMapViewAnimated:(BOOL)animated;
- (void)dismissMapViewAnimated:(BOOL)animated;
- (void)toggleMapViewAnimated:(BOOL)animated;

#pragma mark Working with the error view

- (UIView *)errorViewInstanceForError:(NSError *)error;
- (NSString *)alertViewTitleForError:(NSError *)error;
- (NSString *)alertViewMessageForError:(NSError *)error;

#pragma mark Working with the no data view

- (UIView *)noDataViewInstance;

#pragma mark Working with category filters

- (NSArray *)categoryFilters;
- (void)didSelectCategoryFilter:(CategoryFilter *)filter;

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

//
// Note that since it was decided that user log in wouldn't make it until
// the next version, these are no longer used.
//
- (BOOL)shouldResetForAccountAddition:(LokaliteAccount *)account;
- (BOOL)shouldResetForAccountDeletion:(LokaliteAccount *)account;

#pragma mark Fetching data from the network

- (void)processNextBatchOfFetchedObjects:(NSArray *)objects
                              pageNumber:(NSInteger)pageNumber;
- (void)processObjectFetchError:(NSError *)error
                     pageNumber:(NSInteger)pageNumber;

- (LokaliteStream *)lokaliteStreamInstance;

@end
