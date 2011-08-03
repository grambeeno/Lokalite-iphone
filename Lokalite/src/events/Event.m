//
//  Event.m
//  Lokalite
//
//  Created by John Debay on 7/27/11.
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
@dynamic startDate;
@dynamic featured;
@dynamic imageUrl;
@dynamic identifier;
@dynamic imageData;
@dynamic name;
@dynamic trended;
@dynamic category;
@dynamic venue;
@dynamic business;

#pragma mark - LokaliteObject implementation

- (UIImage *)image
{
    NSData *data = [self imageData];
    return data ? [UIImage imageWithData:data] : nil;
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
