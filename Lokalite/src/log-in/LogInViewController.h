//
//  LogInViewController.h
//  Lokalite
//
//  Created by John Debay on 7/25/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LogInViewControllerDelegate;

@interface LogInViewController : UITableViewController <UITextFieldDelegate>

@property (nonatomic, assign) id<LogInViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITableViewCell *usernameCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordCell;

@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

#pragma mark - Initialization

- (id)init;

@end


@protocol LogInViewControllerDelegate <NSObject>

- (void)logInViewController:(LogInViewController *)controller
       didLogInWithUsername:(NSString *)username
                   password:(NSString *)password;
- (void)logInViewControllerDidCancel:(LogInViewController *)controller;

@end
