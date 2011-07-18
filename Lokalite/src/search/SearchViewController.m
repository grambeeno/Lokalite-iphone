//
//  SearchViewController.m
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "SearchViewController.h"


enum {
    kSectionEventSearchResults,
    kSectionBusinessSearchResults
};


@interface SearchViewController ()

@property (nonatomic, copy) NSArray *eventSearchResults;
@property (nonatomic, copy) NSArray *businessSearchResults;

#pragma mark - View initialization

- (void)initializeSearchBar;

#pragma mark - Table view management

- (NSInteger)effectiveSectionForSection:(NSInteger)section;

@end

@implementation SearchViewController

@synthesize searchDisplayController = searchDisplayController_;
@synthesize searchBar = searchBar_;

@synthesize eventSearchResults = eventSearchResults_;
@synthesize businessSearchResults = businessSearchResults_;

#pragma mark - Memory management

- (void)dealloc
{
    [searchDisplayController_ release];
    [searchBar_ release];

    [eventSearchResults_ release];
    [businessSearchResults_ release];

    [super dealloc];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeSearchBar];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    return io == UIInterfaceOrientationPortrait;
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger nsections = 0;

    if ([[self eventSearchResults] count] > 0)
        ++nsections;
    if ([[self businessSearchResults] count] > 0)
        ++nsections;

    return nsections;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    section = [self effectiveSectionForSection:section];
    NSInteger nrows = 0;

    switch (section) {
        case kSectionEventSearchResults:
            nrows = [[self eventSearchResults] count];
            break;
        case kSectionBusinessSearchResults:
            nrows = [[self businessSearchResults] count];
            break;
    }

    return nrows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
        cell =
            [[[UITableViewCell alloc]
              initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:CellIdentifier] autorelease];

    return cell;
}

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
}

#pragma mark - View initialization

- (void)initializeSearchBar
{
    [[self searchBar] setShowsScopeBar:NO];
}

#pragma mark - Table view management

- (NSInteger)effectiveSectionForSection:(NSInteger)section
{
    return section;
}

@end
