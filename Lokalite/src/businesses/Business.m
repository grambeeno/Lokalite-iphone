//
//  Business.m
//  Lokalite
//
//  Created by John Debay on 8/15/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import "Business.h"
#import "Category.h"
#import "Event.h"
#import "Location.h"

#import "Business+GeneralHelpers.h"
#import "Location+GeneralHelpers.h"
#import "LokaliteObjectMapAnnotation.h"

@implementation Business
@dynamic phone;
@dynamic summary;
@dynamic fullImageUrl;
@dynamic url;
@dynamic name;
@dynamic fullImageData;
@dynamic largeImageUrl;
@dynamic largeImageData;
@dynamic mediumImageUrl;
@dynamic mediumImageData;
@dynamic smallImageUrl;
@dynamic smallImageData;
@dynamic thumbnailImageUrl;
@dynamic thumbnailImageData;
@dynamic events;
@dynamic categories;
@dynamic location;

#pragma mark - LokaliteObject implementation

- (UIImage *)mapAnnotationViewImage
{
    return [self standardImage];
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

- (NSURL *)addressUrl
{
    return [[self location] addressUrl];
}

- (NSURL *)directionsUrlFromLocation:(CLLocation *)location
{
    CLLocationCoordinate2D coord = [[self locationInstance] coordinate];
    NSString *destString =
        location ?
        [NSString stringWithFormat:@"%f,%f", [location coordinate].latitude,
         [location coordinate].longitude] :
        @"";
    NSString *s =
        [NSString stringWithFormat:
         @"http://maps.google.com/maps?saddr=%@&daddr=%@",
         coord.latitude, coord.longitude, destString];

    return [NSURL URLWithString:s];
}

@end
