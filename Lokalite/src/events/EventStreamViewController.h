//
//  EventStreamViewController.h
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStreamViewController.h"

@class Event;

@interface EventStreamViewController : LokaliteStreamViewController

- (void)fetchImageForEvent:(Event *)event tableView:(UITableView *)tableView;

@end
