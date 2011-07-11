//
//  FirstViewController.m
//  Lokalite
//
//  Created by John Debay on 7/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "FeaturedViewController.h"

@interface FeaturedViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem;
- (void)initializeTableView;

@end

@implementation FeaturedViewController

@synthesize headerView;

#pragma mark - Memory management

- (void)dealloc
{
    [headerView release];
    [super dealloc];
}

#pragma mark - UI events

- (void)toggleMapView:(id)sender
{
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSLog(@"I am a: %@", NSStringFromClass([self class]));
    NSLog(@"View class: %@", NSStringFromClass([[self view] class]));

    [self initializeNavigationItem];
    [self initializeTableView];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    return io == UIInterfaceOrientationPortrait;
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)tableView:(UITableView *)tableView
    numberOfRowsInSection:(NSInteger)section
{
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeaturedTableViewCell";

    UITableViewCell *cell =
        [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell)
        cell =
            [[[UITableViewCell alloc]
              initWithStyle:UITableViewCellStyleDefault
              reuseIdentifier:CellIdentifier] autorelease];

    return cell;
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    UIImage *mapImage = [UIImage imageNamed:@"radar"];
    UIBarButtonItem *mapButtonItem =
        [[UIBarButtonItem alloc] initWithImage:mapImage
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(toggleMapView:)];
    [[self navigationItem] setRightBarButtonItem:mapButtonItem];
    [mapButtonItem release], mapButtonItem = nil;
}

- (void)initializeTableView
{
    [[self tableView] setTableHeaderView:[self headerView]];
}

@end
