//
//  Event.m
//  Lokalite
//
//  Created by John Debay on 8/15/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import "Event.h"
#import "Business.h"
#import "Category.h"
#import "Location.h"

#import "Event+GeneralHelpers.h"
#import "LokaliteObjectMapAnnotation.h"

@implementation Event
@dynamic summary;
@dynamic endDate;
@dynamic startDate;
@dynamic trended;
@dynamic featured;
@dynamic imageUrl;
@dynamic imageData;
@dynamic name;
@dynamic distance;
@dynamic location;
@dynamic categories;
@dynamic business;


#pragma mark - LokaliteObject implementation

- (UIImage *)mapAnnotationViewImage
{
    return [self image];
}

- (id<MKAnnotation>)mapAnnotation
{
    return [[[LokaliteObjectMapAnnotation alloc]
             initWithCoordinate:[[self locationInstance] coordinate]
                          title:[self name]
                       subtitle:[self summary]
                         object:self]
            autorelease];
}


@end
