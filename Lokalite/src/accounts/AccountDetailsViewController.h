//
//  AccountDetailsViewController.h
//  Lokalite
//
//  Created by John Debay on 7/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LokaliteAccount;

@protocol AccountDetailsViewControllerDelegate;

@interface AccountDetailsViewController : UITableViewController

@property (nonatomic, assign) id<AccountDetailsViewControllerDelegate> delegate;

@property (nonatomic, retain, readonly) LokaliteAccount *account;

@property (nonatomic, retain) IBOutlet UIView *headerView;

#pragma mark - Initialization

- (id)initWithAccount:(LokaliteAccount *)account;

@end


@protocol AccountDetailsViewControllerDelegate <NSObject>

- (void)accountDetailsViewController:(AccountDetailsViewController *)controller
                       logOutAccount:(LokaliteAccount *)account;

@end
