//
//  AllEventsViewController.m
//  Lokalite
//
//  Created by John Debay on 8/3/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "AllEventsViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "LokaliteDownloadSource.h"

#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"
#import "CategoryEventStreamViewController.h"

#import "CategoryFilter.h"

//#import "LokaliteEventStream.h"
#import "LokaliteCategoryStream.h"
#import "LokaliteSearchStream.h"

#import "TableViewImageFetcher.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

@interface AllEventsViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem;

@end


@implementation AllEventsViewController

#pragma mark - UIViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];

    [self setCanSearchServer:YES];
    [self setShowsCategoryFilter:YES];
    [self setRequiresLocation:YES];
}

#pragma mark - LokaliteStreamViewController implementation

#pragma mark Configuring the view

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.events", nil);
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
    return [LokaliteSearchStream eventSearchStreamWithKeywords:keywords
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
    LokaliteStream *stream =
        [LokaliteCategoryStream eventStreamWithCategoryName:serverFilter
                                                    context:moc];
    CategoryEventStreamViewController *controller =
        [[CategoryEventStreamViewController alloc] initWithCategoryName:name
                                                         lokaliteStream:stream
                                                                context:moc];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

- (LokaliteStream *)lokaliteStreamInstance
{
    return [LokaliteCategoryStream eventStreamWithCategoryName:nil
                                                       context:[self context]];
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    [[self navigationItem] setLeftBarButtonItem:[self refreshButtonItem]];
    [[self navigationItem] setRightBarButtonItem:[self mapViewButtonItem]];
}

@end
