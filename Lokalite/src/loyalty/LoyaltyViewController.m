//
//  SecondViewController.m
//  Lokalite
//
//  Created by John Debay on 7/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LoyaltyViewController.h"

@implementation LoyaltyViewController

#pragma mark - UITableViewController implementation

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
    return nil;
}

@end
