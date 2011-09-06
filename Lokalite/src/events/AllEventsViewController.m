//
//  AllEventsViewController.m
//  Lokalite
//
//  Created by John Debay on 8/3/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "AllEventsViewController.h"

#import "CategoryEventStreamViewController.h"

#import "CategoryLokaliteStream.h"
#import "SearchLokaliteStream.h"

#import "TableViewImageFetcher.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"


enum {
    EventFilterStartTime,
    EventFilterDistance
};


@interface AllEventsViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem;

#pragma mark - Location updates

- (void)subscribeForLocationNotifications;
- (void)unsubscribeForLocationNotifications;
- (void)processLocationUpdate:(CLLocation *)location;
- (void)processLocationUpdateFailure:(NSError *)error;

@end


@implementation AllEventsViewController

@synthesize eventSelector = eventSelector_;

#pragma mark - Memory management

- (void)dealloc
{
    [self unsubscribeForLocationNotifications];

    [eventSelector_ release];
    [super dealloc];
}

#pragma mark - UI events

- (IBAction)eventSelectorValueChanged:(id)sender
{
    [self refresh:nil];
}

#pragma mark - UIViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];

    [self setCanSearchServer:YES];
    [self setShowsCategoryFilter:YES];
    [self setRequiresLocation:YES];

    DeviceLocator *locator = [DeviceLocator locator];
    if ([locator lastError] && ![locator lastLocation])
        [[self navigationItem] setTitleView:nil];

    [self subscribeForLocationNotifications];
}

#pragma mark - LokaliteStreamViewController implementation

#pragma mark Configuring the view

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.events", nil);
}

#pragma mark - Working with the local data store

- (NSArray *)dataControllerSortDescriptors
{
    BOOL distanceSelected =
        [[self eventSelector] selectedSegmentIndex] == EventFilterDistance;
    BOOL hasLocation =
        distanceSelected &&
        [self requiresLocation] &&
        CLLocationCoordinate2DIsValid([[self lokaliteStream] location]);

    return
        hasLocation ?
        [Event locationTableViewSortDescriptors] :
        [Event dateTableViewSortDescriptors];
}

- (NSString *)dataControllerSectionNameKeyPath
{
    BOOL distanceSelected =
        [[self eventSelector] selectedSegmentIndex] == EventFilterDistance;
    BOOL hasLocation =
        distanceSelected &&
        [self requiresLocation] &&
        CLLocationCoordinate2DIsValid([[self lokaliteStream] location]);

    return hasLocation ? @"distanceDescription" : @"dateDescription";
}

#pragma mark - Search - remote

- (NSPredicate *)predicateForQueryString:(NSString *)queryString
{
    return [Event predicateForSearchString:queryString
                             includeEvents:YES
                         includeBusinesses:YES];
}

- (LokaliteStream *)remoteSearchLokaliteStreamInstanceForKeywords:
    (NSString *)keywords
{
    return [SearchLokaliteStream eventSearchStreamWithKeywords:keywords
                                                      category:nil
                                                       context:[self context]];
}

#pragma mark - Working with category filters

- (NSArray *)categoryFilters
{
    return [CategoryFilter defaultEventFilters];
}

- (void)didSelectCategoryFilter:(CategoryFilter *)filter
{
    NSManagedObjectContext *moc = [self context];

    NSString *serverFilter = [filter serverFilter];
    NSString *name = [filter name];
    NSString *shortName = [filter shortName];
    LokaliteStream *stream =
        [CategoryLokaliteStream eventStreamWithCategoryName:serverFilter
                                                    context:moc];
    CategoryEventStreamViewController *controller =
        [[CategoryEventStreamViewController alloc]
         initWithCategoryName:name
                    shortName:shortName
               lokaliteStream:stream
                      context:moc];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

- (LokaliteStream *)lokaliteStreamInstance
{
    NSManagedObjectContext *context = [self context];
    NSInteger idx = [[self eventSelector] selectedSegmentIndex];

    NSString *orderBy =
        idx == EventFilterStartTime ? @"starts_at" : @"distance";
    LokaliteStream *stream =
        [CategoryLokaliteStream eventStreamWithCategoryName:nil
                                                    context:context];
    [stream setOrderBy:orderBy];

    return stream;
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setLeftBarButtonItem:[self refreshButtonItem]];
    [[self navigationItem] setRightBarButtonItem:[self mapViewButtonItem]];
}

#pragma mark - Location updates

- (void)subscribeForLocationNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(processLocationUpdateNotification:)
               name:DeviceLocatorDidUpdateLocationNotificationName
             object:[DeviceLocator locator]];
    [nc addObserver:self
           selector:@selector(processLocationUpdateFailureNotification:)
               name:DeviceLocatorDidUpdateLocationErrorNotificationName
             object:[DeviceLocator locator]];
}

- (void)unsubscribeForLocationNotifications
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:DeviceLocatorDidUpdateLocationNotificationName
                object:[DeviceLocator locator]];
    [nc removeObserver:self
                  name:DeviceLocatorDidUpdateLocationErrorNotificationName
                object:[DeviceLocator locator]];
}

- (void)processLocationUpdateNotification:(NSNotification *)notification
{
    CLLocation *location =
        [[notification userInfo] objectForKey:DeviceLocatorLocationKey];
    [self processLocationUpdate:location];
}

- (void)processLocationUpdateFailureNotification:(NSNotification *)notification
{
    DeviceLocator *locator = [notification object];
    if (![locator lastLocation]) {
        NSError *error =
            [[notification userInfo]
             objectForKey:DeviceLocatorLocationErrorKey];
        [self processLocationUpdateFailure:error];
    }
}

- (void)processLocationUpdate:(CLLocation *)location
{
    NSLog(@"%@: processing location update: %@",
          NSStringFromClass([self class]), location);

    UINavigationItem *navItem = [self navigationItem];
    if (![navItem titleView]) {
        [[self eventSelector] setSelectedSegmentIndex:EventFilterStartTime];
        [navItem setTitleView:[self eventSelector]];
    }
}

- (void)processLocationUpdateFailure:(NSError *)error
{
    if ([[self eventSelector] selectedSegmentIndex] == EventFilterDistance) {
        [[self eventSelector] setSelectedSegmentIndex:EventFilterStartTime];
        [self eventSelectorValueChanged:[self eventSelector]];
    }

    [[self navigationItem] setTitleView:nil];
}

@end
