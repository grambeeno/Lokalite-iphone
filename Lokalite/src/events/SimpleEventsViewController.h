//
//  SimpleEventsViewController.h
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventStreamViewController.h"

@class LokaliteStream;

@interface SimpleEventsViewController : EventStreamViewController

@property (nonatomic, copy, readonly) NSString *categoryName;
@property (nonatomic, retain) LokaliteStream *providedLokaliteStream;

#pragma mark - Initialization

- (id)initWithCategoryName:(NSString *)categoryName
            lokaliteStream:(LokaliteStream *)stream
                   context:(NSManagedObjectContext *)context;

@end
