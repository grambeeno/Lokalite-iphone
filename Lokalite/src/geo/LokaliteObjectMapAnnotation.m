//
//  EventMapAnnotation.m
//  Lokalite
//
//  Created by John Debay on 8/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteObjectMapAnnotation.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation LokaliteObjectMapAnnotation

@synthesize lokaliteObject = lokaliteObject_;

#pragma mark - Memory management

- (void)dealloc
{
    [title_ release];
    [subtitle_ release];

    [lokaliteObject_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString *)title
                subtitle:(NSString *)subtitle
                  object:(id<MappableLokaliteObject>)object
{
    self = [super init];
    if (self) {
        coordinate_ = coordinate;
        title_ = [title copy];
        subtitle_ = [subtitle copy];
        lokaliteObject_ = [object retain];
    }

    return self;
}

#pragma mark - MKAnnotation implementation

- (CLLocationCoordinate2D)coordinate
{
    return coordinate_;
}

- (NSString *)title
{
    return title_;
}

- (NSString *)subtitle
{
    return subtitle_;
}

@end
