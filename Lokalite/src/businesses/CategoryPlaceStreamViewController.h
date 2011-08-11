//
//  CategoryPlaceStreamViewController.h
//  Lokalite
//
//  Created by John Debay on 8/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlaceStreamViewController.h"

@class LokaliteStream;

@interface CategoryPlaceStreamViewController : PlaceStreamViewController

@property (nonatomic, copy, readonly) NSString *categoryName;
@property (nonatomic, retain) LokaliteStream *providedLokaliteStream;

#pragma mark - Initialization

- (id)initWithCategoryName:(NSString *)categoryName
            lokaliteStream:(LokaliteStream *)stream
                   context:(NSManagedObjectContext *)context;

@end
