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
    <UIActionSheetDelegate>

@property (nonatomic, retain, readonly) Event *event;

@property (nonatomic, retain) IBOutlet EventDetailsHeaderView *headerView;
@property (nonatomic, retain) LocationTableViewCell *locationMapCell;
@property (nonatomic, retain) IBOutlet EventDetailsFooterView *footerView;

#pragma mark - Initialization

- (id)initWithEvent:(Event *)event;

#pragma mark - Button actions

- (IBAction)toggleTrendStatus:(id)sender;

@end
