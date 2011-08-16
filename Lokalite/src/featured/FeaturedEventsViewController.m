//
//  FeaturedEventsViewController.m
//  Lokalite
//
//  Created by John Debay on 7/27/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "FeaturedEventsViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"

#import "LokaliteFeaturedEventStream.h"

#import "TableViewImageFetcher.h"

#import "MapDisplayController.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface FeaturedEventsViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem;

@end


@implementation FeaturedEventsViewController

#pragma mark - LokaliteStreamViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];

    [self setShowsSearchBar:NO];
    [self setRequiresLocation:YES];
}

#pragma mark Configuring the view

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.featured", nil);
}

#pragma mark Working with the local data store

- (NSPredicate *)dataControllerPredicate
{
    NSManagedObjectContext *context = [self context];
    NSDate *date =
        [[LokaliteApplicationState currentState:context] dataFreshnessDate];
    LokaliteDownloadSource *source = [[self lokaliteStream] downloadSource];
    NSString *sourceName = [source name];

    NSPredicate *all =
        [NSPredicate predicateForDownloadSourceName:sourceName
                                    lastUpdatedDate:date];
    NSPredicate *featured =
        [NSPredicate predicateWithFormat:@"featured == YES"];
    NSArray *subpredicates = [NSArray arrayWithObjects:featured, all, nil];

    return [NSCompoundPredicate andPredicateWithSubpredicates:subpredicates];
}

#pragma mark Fetching data from the network

- (void)processNextBatchOfFetchedObjects:(NSArray *)objects
                              pageNumber:(NSInteger)pageNumber
{
    [super processNextBatchOfFetchedObjects:objects pageNumber:pageNumber];
    [objects makeObjectsPerformSelector:@selector(setFeatured:)
                             withObject:[NSNumber numberWithBool:YES]];
}

- (LokaliteStream *)lokaliteStreamInstance
{
    return [LokaliteFeaturedEventStream streamWithContext:[self context]];
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setLeftBarButtonItem:[self refreshButtonItem]];
    [[self navigationItem] setRightBarButtonItem:[self mapViewButtonItem]];
}

@end
