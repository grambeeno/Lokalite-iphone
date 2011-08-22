//
//  TrendedEventsViewController.h
//  Lokalite
//
//  Created by John Debay on 8/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

//
// Shows events trended by the user.
//

@interface TrendedEventsViewController : UITableViewController
    <NSFetchedResultsControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *context;

@end