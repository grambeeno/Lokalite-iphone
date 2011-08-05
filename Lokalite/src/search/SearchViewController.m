//
//  SearchViewController.m
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "SearchViewController.h"

#import "LokaliteSearchStream.h"

#import "SDKAdditions.h"

enum {
    kSectionEventSearchResults,
    kSectionBusinessSearchResults
};


@interface SearchViewController ()

@property (nonatomic, copy) NSArray *eventSearchResults;
@property (nonatomic, copy) NSArray *businessSearchResults;

@property (nonatomic, retain) LokaliteSearchStream *stream;

#pragma mark - View initialization

- (void)initializeSearchBar;

#pragma mark - Table view management

- (NSInteger)effectiveSectionForSection:(NSInteger)section;

#pragma mark - Search implementation

- (void)searchForKeywordComponents:(NSArray *)components
                     includeEvents:(BOOL)includeEvents
                 includeBusinesses:(BOOL)includeBusinesses;

@end

@implementation SearchViewController

@synthesize context = context_;

@synthesize searchDisplayController = searchDisplayController_;
@synthesize searchBar = searchBar_;

@synthesize eventSearchResults = eventSearchResults_;
@synthesize businessSearchResults = businessSearchResults_;

@synthesize stream = stream_;

#pragma mark - Memory management

- (void)dealloc
{
    [context_ release];

    [searchDisplayController_ release];
    [searchBar_ release];

    [eventSearchResults_ release];
    [businessSearchResults_ release];

    [stream_ release];

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

#pragma mark - UISearchBarDelegate implementation

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *keywords = [searchBar text];
    if ([keywords length]) {
        NSArray *components = [keywords arrayByTokenizingWithString:@" "];
        NSLog(@"Components: %@", components);
        if ([components count]) {
            // start search here
            [self searchForKeywordComponents:components
                               includeEvents:YES
                           includeBusinesses:YES];
        }
    }
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

#pragma mark - Search implementation

- (void)searchForKeywordComponents:(NSArray *)components
                     includeEvents:(BOOL)includeEvents
                 includeBusinesses:(BOOL)includeBusinesses
{
    [[self stream] setKeywords:components];
    [[self stream] setIncludeEvents:includeEvents];
    [[self stream] setIncludeBusinesses:includeBusinesses];

    [[self stream] fetchNextBatchWithResponseHandler:
     ^(NSArray *objects, NSError *error) {
         NSLog(@"Fetched %d objects.", [objects count]);
         NSLog(@"%@", objects);
     }];
}

#pragma mark - Accessors

- (LokaliteSearchStream *)stream
{
    if (!stream_) {
        NSAssert(0, @"Not implemented");
        stream_ =
            [[LokaliteSearchStream streamWithDownloadSourceName:nil
                                                        context:[self context]]
             retain];
    }

    return stream_;
}

@end
