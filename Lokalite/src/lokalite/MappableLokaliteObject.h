//
//  MappableLokaliteObject.h
//  Lokalite
//
//  Created by John Debay on 8/2/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MappableLokaliteObject <NSObject>

- (UIImage *)mapAnnotationViewImage;

- (id<MKAnnotation>)mapAnnotation;

- (NSURL *)addressUrl;
- (NSURL *)directionsUrlFromLocation:(CLLocation *)location;

- (NSString *)pluralTitle;

@end
