//
//  TwitterXAuthLogInViewController.h
//  Lokalite
//
//  Created by John Debay on 8/23/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TwitterXauthenticator.h"

@protocol TwitterXAuthLogInViewControllerDelegate;

@interface TwitterXAuthLogInViewController : UITableViewController
    <UITextFieldDelegate, TwitterXauthenticatorDelegate>

@property (nonatomic, assign)
    id<TwitterXAuthLogInViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet UITableViewCell *usernameCell;
@property (nonatomic, retain) IBOutlet UITextField *usernameTextField;
@property (nonatomic, retain) IBOutlet UITableViewCell *passwordCell;
@property (nonatomic, retain) IBOutlet UITextField *passwordTextField;

@end


@protocol TwitterXAuthLogInViewControllerDelegate <NSObject>

- (void)twitterLogInViewController:(TwitterXAuthLogInViewController *)controller
                  didLogInUsername:(NSString *)username
                            userId:(NSNumber *)userId
                             token:(NSString *)token
                            secret:(NSString *)secret;

- (void)twitterLogInViewControllerDidCancel:
    (TwitterXAuthLogInViewController *)controller;

@end
