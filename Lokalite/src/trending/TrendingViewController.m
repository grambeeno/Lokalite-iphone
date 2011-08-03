//
//  TrendingViewController.m
//  Lokalite
//
//  Created by John Debay on 7/29/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TrendingViewController.h"

#import "Event.h"

#import "LokaliteEventStream.h"

#import "SDKAdditions.h"

@interface TrendingViewController ()

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

- (NSString *)lokaliteObjectEntityName
{
    return @"Event";
}

- (NSArray *)dataControllerSortDescriptors
{
    NSSortDescriptor *sd1 =
        [NSSortDescriptor sortDescriptorWithKey:@"endDate" ascending:YES];
    NSSortDescriptor *sd2 =
        [NSSortDescriptor sortDescriptorWithKey:@"name" ascending:YES];

    return [NSArray arrayWithObjects:sd1, sd2, nil];
}

- (LokaliteStream *)lokaliteStreamInstance
{
    return [LokaliteEventStream streamWithContext:[self context]];
}

- (void)configureCell:(UITableViewCell *)cell forObject:(Event *)event
{
    [[cell textLabel] setText:[event name]];
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setRightBarButtonItem:
     [self toggleMapViewButtonItem]];
}

@end
