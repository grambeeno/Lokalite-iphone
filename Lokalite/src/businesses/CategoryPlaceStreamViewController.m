//
//  CategoryPlaceStreamViewController.m
//  Lokalite
//
//  Created by John Debay on 8/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "CategoryPlaceStreamViewController.h"

#import "LokaliteStream.h"

@implementation CategoryPlaceStreamViewController

@synthesize categoryName = categoryName_;
@synthesize providedLokaliteStream = providedLokaliteStream_;

#pragma mark - Memory management

- (void)dealloc
{
    [categoryName_ release];
    [providedLokaliteStream_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithCategoryName:(NSString *)categoryName
            lokaliteStream:(LokaliteStream *)stream
                   context:(NSManagedObjectContext *)context
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        categoryName_ = [categoryName copy];
        providedLokaliteStream_ = [stream retain];
        [self setContext:context];
    }

    return self;
}

#pragma mark - PlaceStreamViewController implementation

- (LokaliteStream *)lokaliteStreamInstance
{
    return [self providedLokaliteStream];
}

- (NSString *)titleForView
{
    return [self categoryName];
}

@end