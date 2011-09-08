//
//  TrendedEventsViewController.h
//  Lokalite
//
//  Created by John Debay on 8/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>

#import "SettingsViewController.h"

@class Event;

@interface TrendedEventsViewController : UITableViewController
    <NSFetchedResultsControllerDelegate,
     SettingsViewControllerDelegate>

@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) IBOutlet UIBarButtonItem *settingsButtonItem;
@property (nonatomic, retain) IBOutlet UISegmentedControl *timeSelector;

#pragma mark - UI events

- (IBAction)timeSelectorValueChanged:(id)sender;
- (IBAction)presentSettings:(id)sender;

#pragma mark - Load details for a specific event

- (void)showDetailsForEvent:(Event *)event animated:(BOOL)animated;

@end
