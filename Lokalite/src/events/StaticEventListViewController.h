//
//  StaticEventListViewController.h
//  Lokalite
//
//  Created by John Debay on 9/2/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StaticEventListViewController : UITableViewController

@property (nonatomic, copy, readonly) NSArray *events;

#pragma mark - Initialization

- (id)initWithEvents:(NSArray *)events;

@end
