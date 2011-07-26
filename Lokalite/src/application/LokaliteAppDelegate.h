//
//  LokaliteAppDelegate.h
//  Lokalite
//
//  Created by John Debay on 7/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "AccountDetailsViewController.h"

@interface LokaliteAppDelegate : NSObject
    <UIApplicationDelegate, UITabBarControllerDelegate, UIActionSheetDelegate,
     AccountDetailsViewControllerDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

#pragma mark - Displaying the application activity view

- (void)displayActivityViewAnimated:(BOOL)animated;
- (void)displayActivityViewAnimated:(BOOL)animated
                         completion:(void(^)(void))completion;
- (void)hideActivityViewAnimated:(BOOL)animated;
- (void)hideActivityViewAnimated:(BOOL)animated
                      completion:(void(^)(void))completion;

@end
