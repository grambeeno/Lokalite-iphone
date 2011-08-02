//
//  EventMapAnnotation.m
//  Lokalite
//
//  Created by John Debay on 8/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventMapAnnotation.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation EventMapAnnotation

@synthesize event = event_;

#pragma mark - Memory management

- (void)dealloc
{
    [event_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithEvent:(Event *)event
{
    self = [super init];
    if (self)
        event_ = [event retain];

    return self;
}

#pragma mark - MKAnnotation implementation

- (CLLocationCoordinate2D)coordinate
{
    return [[[self event] location] coordinate];
}

- (NSString *)title
{
    return [[self event] name];
}

- (NSString *)subtitle
{
    return [[self event] summary];
}

@end
