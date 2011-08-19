//
//  TrendingViewController.m
//  Lokalite
//
//  Created by John Debay on 7/29/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TrendingViewController.h"

#import "LokaliteTrendingEventStream.h"

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
        [NSSortDescriptor sortDescriptorWithKey:@"usersCount" ascending:NO];
    NSSortDescriptor *sd2 =
        [NSSortDescriptor sortDescriptorWithKey:@"startDate" ascending:YES];

    return [NSArray arrayWithObjects:sd1, sd2, nil];
}

#pragma mark Fetching data from the network

- (LokaliteStream *)lokaliteStreamInstance
{
    return [LokaliteTrendingEventStream streamWithContext:[self context]];
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setLeftBarButtonItem:[self refreshButtonItem]];
    [[self navigationItem] setRightBarButtonItem:[self mapViewButtonItem]];
}

@end
