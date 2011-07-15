//
//  EventDetailsViewController.h
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event, EventDetailsHeaderView;
@class LocationTableViewCell;

@interface EventDetailsViewController : UITableViewController

@property (nonatomic, retain, readonly) Event *event;

@property (nonatomic, retain) IBOutlet EventDetailsHeaderView *headerView;
@property (nonatomic, retain) LocationTableViewCell *locationMapCell;
@property (nonatomic, retain) IBOutlet UIView *footerView;

#pragma mark - Initialization

- (id)initWithEvent:(Event *)event;

@end
