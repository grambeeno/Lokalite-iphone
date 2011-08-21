//
//  PlaceEventStreamViewController.h
//  Lokalite
//
//  Created by John Debay on 8/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventStreamViewController.h"

@class Business;

@interface PlaceEventStreamViewController : EventStreamViewController

@property (nonatomic, retain, readonly) Business *place;

#pragma mark - Initialization

- (id)initWithPlace:(Business *)place;

@end
