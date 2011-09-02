//
//  StaticPlaceListViewController.m
//  Lokalite
//
//  Created by John Debay on 9/2/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "StaticPlaceListViewController.h"

#import "Business.h"

#import "PlaceTableViewCell.h"
#import "BusinessDetailsViewController.h"

#import "SDKAdditions.h"

@implementation StaticPlaceListViewController

@synthesize places = places_;

#pragma mark - Memory management

- (void)dealloc
{
    [places_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithPlaces:(NSArray *)places
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        places_ = [places copy];
        [self setTitle:NSLocalizedString(@"global.places", nil)];
    }

    return self;
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self tableView] setBackgroundColor:[UIColor tableViewBackgroundColor]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setRowHeight:[PlaceTableViewCell cellHeight]];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[self places] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [PlaceTableViewCell defaultReuseIdentifier];

    PlaceTableViewCell *cell = (PlaceTableViewCell *)
        [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
        cell = [PlaceTableViewCell instanceFromNib];

    [cell configureCellForPlace:[[self places] objectAtIndex:[indexPath row]]
                displayDistance:YES];
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Business *place = [[self places] objectAtIndex:[indexPath row]];
    BusinessDetailsViewController *controller =
        [[BusinessDetailsViewController alloc] initWithBusiness:place];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

@end
