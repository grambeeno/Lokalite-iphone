//
//  LokaliteAppDelegate.h
//  Lokalite
//
//  Created by John Debay on 7/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LokaliteAppDelegate : NSObject
    <UIApplicationDelegate, UITabBarControllerDelegate>

@property (nonatomic, retain) IBOutlet UIWindow *window;

@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;

@end
