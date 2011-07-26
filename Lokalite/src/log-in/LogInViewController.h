//
//  LogInViewController.h
//  Lokalite
//
//  Created by John Debay on 7/25/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSManagedObjectContext;
@protocol LogInViewControllerDelegate;

@interface LogInViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, assign) id<LogInViewControllerDelegate> delegate;

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) IBOutlet UITableViewCell *usernameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordCell;

@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

#pragma mark - Initialization

- (id)initWithContext:(NSManagedObjectContext *)context;

@end



@class LokaliteAccount;

@protocol LogInViewControllerDelegate <NSObject>

- (void)logInViewController:(LogInViewController *)controller
        didLogInWithAccount:(LokaliteAccount *)account;
- (void)logInViewControllerDidCancel:(LogInViewController *)controller;

@end
