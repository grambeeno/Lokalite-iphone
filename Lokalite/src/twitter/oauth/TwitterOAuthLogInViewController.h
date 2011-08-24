//
//  TwitterOAuthLogInViewController.h
//  Lokalite
//
//  Created by John Debay on 8/23/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "TwitterOAuthAuthenticator.h"
#import "TwitterOAuthWebView.h"

typedef void(^oauth_log_in_did_start_handler_t)(void);
typedef void(^oauth_log_in_did_succeed_handler_t)(NSNumber *userId,
                                                  NSString *username,
                                                  NSString *token,
                                                  NSString *secret);
typedef void(^oauth_log_in_did_fail_handler_t)(NSError *error);

@interface TwitterOAuthLogInViewController : UITableViewController
    <TwitterOAuthAuthenticatorDelegate, TwitterOAuthWebViewDelegate>

@property (nonatomic, retain) IBOutlet UITableViewCell *authorizeCell;
@property (nonatomic, retain) IBOutlet UITableViewCell *contactingTwitterCell;

@property (nonatomic, assign) BOOL canCancel;

@property (nonatomic, copy)
    oauth_log_in_did_start_handler_t logInDidStartHandler;
@property (nonatomic, copy)
    oauth_log_in_did_succeed_handler_t logInDidSucceedHandler;
@property (nonatomic, copy) oauth_log_in_did_fail_handler_t logInDidFailHandler;

#pragma mark - Initialization

- (id)init;

@end
