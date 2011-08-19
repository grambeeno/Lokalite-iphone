//
//  LocationTableViewCell.m
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LocationTableViewCell.h"

#import <MapKit/MapKit.h>

#import "MKMapView+GeneralHelpers.h"

static const NSInteger ZOOM_LEVEL = 14;

@implementation LocationTableViewCell

@synthesize mapView = mapView_;
@synthesize location = location_;

#pragma mark - Configuring the map view

- (void)centerMapViewOnLocation:(CLLocation *)location animated:(BOOL)animated
{
    CLLocationCoordinate2D coordinate = [location coordinate];
    const NSInteger zoom = ZOOM_LEVEL;

    [[self mapView] setCenterCoordinate:coordinate
                              zoomLevel:zoom
                               animated:animated];
}

#pragma mark - MKMapViewDelegate implementation

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    NSString *identifier = @"PinAnnotation";
    MKPinAnnotationView *view = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:identifier];
    if (!view) {
        view = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                reuseIdentifier:identifier]
                autorelease];
        [view setAnimatesDrop:NO];
        [view setPinColor:MKPinAnnotationColorGreen];
        [view setCanShowCallout:NO];
    }

    return view;
}

#pragma mark - Accessors

- (void)setLocation:(CLLocation *)location
{
    if (location != location_) {
        [location_ release];
        location_ = [location retain];

        [self centerMapViewOnLocation:location_ animated:NO];

        MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
        [annotation setCoordinate:[location coordinate]];
        [[self mapView] addAnnotation:annotation];
        [annotation release], annotation = nil;
    }
}

+ (CGFloat)cellHeight
{
    return 120;
}

@end
