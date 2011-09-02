//
//  StaticPlaceListViewController.h
//  Lokalite
//
//  Created by John Debay on 9/2/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaticPlaceListViewController : UITableViewController

@property (nonatomic, copy, readonly) NSArray *places;

#pragma mark - Initialization

- (id)initWithPlaces:(NSArray *)places;

@end
