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

@interface PlacesViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem;

@end


@implementation PlacesViewController

#pragma mark - UIViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];

    [self setCanSearchServer:YES];
    [self setShowsCategoryFilter:YES];
}

#pragma mark - LokaliteStreamViewController implementation

#pragma mark Configuring the view

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.places", nil);
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
    return [PlacesLokaliteStream streamWithContext:[self context]];
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setLeftBarButtonItem:[self refreshButtonItem]];
    [[self navigationItem] setRightBarButtonItem:[self mapViewButtonItem]];
}

@end
