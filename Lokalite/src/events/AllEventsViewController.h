//
//  AllEventsViewController.h
//  Lokalite
//
//  Created by John Debay on 8/3/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventStreamViewController.h"

@interface AllEventsViewController : EventStreamViewController

@property (nonatomic, retain) IBOutlet UISegmentedControl *eventSelector;

#pragma mark - UI events

- (IBAction)eventSelectorValueChanged:(id)sender;

@end
