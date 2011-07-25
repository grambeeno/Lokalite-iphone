//
//  PlacesViewController.m
//  Lokalite
//
//  Created by John Debay on 7/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlacesViewController.h"

#import "PlaceTableViewCell.h"
#import "UITableViewCell+GeneralHelpers.h"

#import "LokaliteStream.h"
#import "LokalitePlacesStream.h"

@implementation PlacesViewController

#pragma mark - LokaliteStreamViewController implementation

- (NSString *)lokaliteObjectEntityName
{
    return @"Business";
}

- (NSArray *)dataControllerSortDescriptors
{
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                         ascending:YES];
    return [NSArray arrayWithObject:sd];
}

- (LokaliteStream *)lokaliteStreamInstance
{
    return [LokalitePlacesStream streamWithContext:[self context]];
}

#pragma mark - Configuring the table view

- (CGFloat)cellHeightForTableView:(UITableView *)tableView
{
    return [PlaceTableViewCell cellHeight];
}

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView
{
    return [PlaceTableViewCell defaultReuseIdentifier];
}

- (UITableViewCell *)tableViewCellInstanceForTableView:(UITableView *)tableView
                                       reuseIdentifier:(NSString *)identifier
{
    return [PlaceTableViewCell instanceFromNib];
}

- (void)configureCell:(PlaceTableViewCell *)cell forObject:(Business *)place
{
    [cell configureCellForPlace:place];
}

@end
