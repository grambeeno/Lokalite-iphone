//
//  NewFeaturedViewController.h
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@class NSManagedObjectContext;

@interface FeaturedViewController : UITableViewController

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) IBOutlet UIView *headerView;

@end
