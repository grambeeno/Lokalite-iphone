//
//  BusinessDetailsViewController.h
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Business, BusinessDetailsHeaderView;

@interface BusinessDetailsViewController : UITableViewController
    <UIGestureRecognizerDelegate>

@property (nonatomic, retain, readonly) Business *business;

@property (nonatomic, retain) IBOutlet BusinessDetailsHeaderView *headerView;

#pragma mark - Initialization

- (id)initWithBusiness:(Business *)business;

@end
