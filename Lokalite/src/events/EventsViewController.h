//
//  EventsViewController.h
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

@interface EventsViewController : UITableViewController <UISearchBarDelegate>

@property (nonatomic, retain) NSManagedObjectContext *context;

@end
