//
//  SettingsViewController.h
//  Lokalite
//
//  Created by John Debay on 8/27/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Facebook.h"

@class NSManagedObjectContext;
@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UITableViewController
    <UIActionSheetDelegate, FBSessionDelegate>

@property (nonatomic, assign) id<SettingsViewControllerDelegate> delegate;

@property (nonatomic, retain, readonly) NSManagedObjectContext *context;

#pragma mark - Initialization

- (id)initWithContext:(NSManagedObjectContext *)context;

@end


@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerIsDone:(SettingsViewController *)controller;

@end
