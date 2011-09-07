//
//  TrendingViewController.m
//  Lokalite
//
//  Created by John Debay on 7/29/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TrendingViewController.h"

#import "Event+GeneralHelpers.h"

#import "EventTableViewCell.h"
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
    [self setRequiresLocation:YES];
    [self setShowsCategoryFilter:NO];
}

#pragma mark - LokaliteStreamViewController implementation

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.trending", nil);
}

#pragma mark Configuring the table view

- (void)configureCell:(EventTableViewCell *)cell
          inTableView:(UITableView *)tableView
            forObject:(Event *)event
{
    NSIndexPath *path = [[self dataController] indexPathForObject:event];
    NSNumber *rank = nil;
    if (path)
        rank = [[NSNumber alloc] initWithInteger:[path row] + 1];

    [cell configureCellForEvent:event
                           rank:rank
                displayDistance:[self hasValidLocation]];

    [rank release], rank = nil;

    UIImage *image = [event standardImage];
    if (!image)
        [self fetchImageForEvent:event tableView:tableView];
    [[cell eventImageView] setImage:image];
}

#pragma mark Persistence management

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
    //
    // Don't provide a key path because we get data back in the order they're
    // trending (per the server). Other ordering, like distance or time, don't
    // make sense in that context.
    //
    return nil;
}

#pragma mark Fetching data from the network

- (LokaliteStream *)lokaliteStreamInstance
{
    TrendingEventLokaliteStream *stream =
        [TrendingEventLokaliteStream streamWithContext:[self context]];
    [stream setOrderBy:@"starts_at"];
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
