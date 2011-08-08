//
//  Event.m
//  Lokalite
//
//  Created by John Debay on 8/8/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import "Event.h"
#import "Business.h"
#import "Category.h"
#import "Venue.h"

#import "Event+GeneralHelpers.h"
#import "LokaliteObjectMapAnnotation.h"

@implementation Event
@dynamic summary;
@dynamic endDate;
@dynamic featured;
@dynamic startDate;
@dynamic trended;
@dynamic imageUrl;
@dynamic imageData;
@dynamic name;
@dynamic categories;
@dynamic venue;
@dynamic business;

#pragma mark - LokaliteObject implementation

- (UIImage *)mapAnnotationViewImage
{
    return [self image];
}

- (id<MKAnnotation>)mapAnnotation
{
    return [[[LokaliteObjectMapAnnotation alloc]
             initWithCoordinate:[[self location] coordinate]
             title:[self name]
             subtitle:[self summary]
             object:self]
            autorelease];
}

@end
