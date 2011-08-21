//
//  PlaceEventStreamViewController.m
//  Lokalite
//
//  Created by John Debay on 8/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlaceEventStreamViewController.h"

#import "LokaliteShared.h"

@implementation PlaceEventStreamViewController

@synthesize place = place_;

#pragma mark - Memory management

- (void)dealloc
{
    [place_ release];
    
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithPlace:(Business *)place
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        place_ = [place retain];
        [self setContext:[place managedObjectContext]];
    }

    return self;
}

#pragma mark - EventStreamViewController implementation

- (LokaliteStream *)lokaliteStreamInstance
{
    Business *place = [self place];
    NSManagedObjectContext *context = [place managedObjectContext];
    return [PlaceEventLokaliteStream streamWithPlace:place context:context];
}

- (NSString *)titleForView
{
    return [[self place] name];
}

@end
