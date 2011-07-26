//
//  ProfileViewController.h
//  Lokalite
//
//  Created by John Debay on 7/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LogInViewController.h"

@class NSManagedObjectContext;

@interface ProfileViewController : UITableViewController
    <LogInViewControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) IBOutlet UIView *headerView;

@end
