//
//  EventDetailsViewController.h
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Event, EventDetailsHeaderView, EventDetailsFooterView;
@class LocationTableViewCell;

@interface EventDetailsViewController : UITableViewController
    <UIGestureRecognizerDelegate, UIAlertViewDelegate>

@property (nonatomic, retain, readonly) Event *event;

@property (nonatomic, retain) IBOutlet EventDetailsHeaderView *headerView;
@property (nonatomic, retain) LocationTableViewCell *locationMapCell;
//@property (nonatomic, retain) IBOutlet EventDetailsFooterView *footerView;
@property (nonatomic, retain) IBOutlet UIView *footerView;
@property (nonatomic, retain) IBOutlet UITableViewCell *trendTableViewCell;

#pragma mark - Initialization

- (id)initWithEvent:(Event *)event;

#pragma mark - Button actions

- (IBAction)toggleTrendStatus:(id)sender;

@end
