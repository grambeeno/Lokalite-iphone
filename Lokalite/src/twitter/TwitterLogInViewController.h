//
//  TwitterLogInViewController.h
//  Lokalite
//
//  Created by John Debay on 8/23/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TwitterXauthenticator.h"

@protocol TwitterLogInViewControllerDelegate;

@interface TwitterLogInViewController : UITableViewController
    <UITextFieldDelegate, TwitterXauthenticatorDelegate>

@property (nonatomic, assign) id<TwitterLogInViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITableViewCell *usernameCell;
@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordCell;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@end


@protocol TwitterLogInViewControllerDelegate <NSObject>

- (void)twitterLogInViewController:(TwitterLogInViewController *)controller
                  didLogInUsername:(NSString *)username
                            userId:(NSNumber *)userId
                             token:(NSString *)token
                            secret:(NSString *)secret;

- (void)twitterLogInViewControllerDidCancel:(TwitterLogInViewController *)ctlr;

@end
