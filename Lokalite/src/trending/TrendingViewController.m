//
//  TrendingViewController.m
//  Lokalite
//
//  Created by John Debay on 7/29/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TrendingViewController.h"

#import "TrendingEventLokaliteStream.h"

@interface TrendingViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem;

@end


@implementation TrendingViewController

#pragma mark - UIViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];

    [self setShowsSearchBar:NO];
    [self setShowsCategoryFilter:NO];
}

#pragma mark - LokaliteStreamViewController implementation

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.trending", nil);
}

#pragma mark - Persistence management

- (NSArray *)dataControllerSortDescriptors
{
    NSSortDescriptor *sd1 =
        [NSSortDescriptor sortDescriptorWithKey:@"trendWeight" ascending:NO];
    NSSortDescriptor *sd2 =
        [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];

    return [NSArray arrayWithObjects:sd1, sd2, nil];
}

- (NSString *)dataControllerSectionNameKeyPath
{
    return @"dateDescription";
}

#pragma mark Fetching data from the network

- (LokaliteStream *)lokaliteStreamInstance
{
    TrendingEventLokaliteStream *stream =
        [TrendingEventLokaliteStream streamWithContext:[self context]];
    // objects per page needs to be high enough so that only one page loads;
    // current expected number of objects from the server is 12
    [stream setObjectsPerPage:15];

    return stream;
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setLeftBarButtonItem:[self refreshButtonItem]];
    [[self navigationItem] setRightBarButtonItem:[self mapViewButtonItem]];
}

@end
