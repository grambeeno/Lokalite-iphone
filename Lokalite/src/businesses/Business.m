//
//  Business.m
//  Lokalite
//
//  Created by John Debay on 8/8/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import "Business.h"
#import "Category.h"
#import "Event.h"
#import "Location.h"

#import "Business+GeneralHelpers.h"
#import "LokaliteObjectMapAnnotation.h"

@implementation Business
@dynamic status;
@dynamic phone;
@dynamic summary;
@dynamic address;
@dynamic imageUrl;
@dynamic email;
@dynamic name;
@dynamic imageData;
@dynamic url;
@dynamic categories;
@dynamic events;
@dynamic location;

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
