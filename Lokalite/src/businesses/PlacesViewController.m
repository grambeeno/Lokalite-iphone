//
//  PlacesViewController.m
//  Lokalite
//
//  Created by John Debay on 7/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlacesViewController.h"

#import "LokaliteAccount.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"
#import "BusinessDetailsViewController.h"
#import "CategoryPlaceStreamViewController.h"

#import "PlaceTableViewCell.h"

#import "LokaliteStream.h"
#import "SearchLokaliteStream.h"
#import "PlacesLokaliteStream.h"
#import "CategoryLokaliteStream.h"

#import "TableViewImageFetcher.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"


enum {
    PlaceFilterStartTime,
    PlaceFilterDistance
};


@interface PlacesViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem;

@end


@implementation PlacesViewController

@synthesize placeSelector = placeSelector_;

#pragma mark - Memory management

- (void)dealloc
{
    [placeSelector_ release];
    [super dealloc];
}

#pragma mark - UI events

- (IBAction)placeSelectorValueChanged:(id)sender
{
    [self refresh:nil];
}

#pragma mark - UIViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];

    [self setCanSearchServer:YES];
    [self setShowsCategoryFilter:/*YES*/ NO];
}

#pragma mark - LokaliteStreamViewController implementation

#pragma mark Configuring the view

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.places", nil);
}

#pragma mark - Working with the local data store

- (NSArray *)dataControllerSortDescriptors
{
    BOOL distanceSelected =
        [[self placeSelector] selectedSegmentIndex] == PlaceFilterDistance;
    BOOL hasLocation =
        distanceSelected &&
        [self requiresLocation] &&
        CLLocationCoordinate2DIsValid([[self lokaliteStream] location]);

    return
        hasLocation ?
        [Business locationTableViewSortDescriptors] :
        [Business nameTableViewSortDescriptors];
}

- (NSString *)dataControllerSectionNameKeyPath
{
    BOOL distanceSelected =
        [[self placeSelector] selectedSegmentIndex] == PlaceFilterDistance;
    BOOL hasLocation =
        distanceSelected &&
        [self requiresLocation] &&
        CLLocationCoordinate2DIsValid([[self lokaliteStream] location]);

    return hasLocation ? @"distanceDescription" : nil;
}

#pragma mark - Search - remote

- (LokaliteStream *)remoteSearchLokaliteStreamInstanceForKeywords:
    (NSString *)keywords
{
    return [SearchLokaliteStream placesSearchStreamWithKeywords:keywords
                                                        context:[self context]];
}

#pragma mark - Working with category filters

- (NSArray *)categoryFilters
{
    return [CategoryFilter defaultPlaceFilters];
}

- (void)didSelectCategoryFilter:(CategoryFilter *)filter
{
    NSManagedObjectContext *context = [self context];

    NSString *serverFilter = [filter serverFilter];
    LokaliteStream *stream =
        [CategoryLokaliteStream placeStreamWithCategoryName:serverFilter
                                                    context:context];
    CategoryPlaceStreamViewController *controller =
        [[CategoryPlaceStreamViewController alloc]
         initWithCategoryName:[filter name]
               lokaliteStream:stream
                      context:context];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

#pragma mark Fetching data from the network

- (LokaliteStream *)lokaliteStreamInstance
{
    NSManagedObjectContext *context = [self context];
    NSInteger idx = [[self placeSelector] selectedSegmentIndex];

    NSString *orderBy = idx == PlaceFilterStartTime ? @"name" : @"distance";
    LokaliteStream *stream =
        [CategoryLokaliteStream placeStreamWithCategoryName:nil
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

@end
