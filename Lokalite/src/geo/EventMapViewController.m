//
//  EventMapViewController.m
//  Lokalite
//
//  Created by John Debay on 8/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventMapViewController.h"

@implementation EventMapViewController

@synthesize mapView = mapView_;
@synthesize annotations = annotations_;

#pragma mark - Memory management

- (void)dealloc
{
    [mapView_ release];
    [annotations_ release];
    
    [super dealloc];
}

#pragma mark - MKMapViewDelegate implmeentation

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    static NSString *AnnotationId = @"MapAnnotation";
    MKPinAnnotationView *view = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationId];
    if (!view) {
        view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                               reuseIdentifier:AnnotationId];
        [view setAnimatesDrop:YES];
        [view setPinColor:MKPinAnnotationColorPurple];
        [view setCanShowCallout:YES];
    }

    return view;
}

#pragma mark - Accessors

- (void)setAnnotations:(NSArray *)annotations
{
    if (annotations_ != annotations) {
        [[self mapView] removeAnnotations:annotations_];

        [annotations_ release];
        annotations_ = [annotations copy];

        [[self mapView] addAnnotations:annotations_];

        MKCoordinateRegion region =
            [[self class] coordinateRegionForMapAnnotations:annotations_];
        [[self mapView] setRegion:region];
    }
}

#pragma mark - Map geometry

+ (MKCoordinateRegion)coordinateRegionForMapAnnotations:(NSArray *)annotations
{
    __block CLLocationDegrees maxLat = -90, minLat = 90;
    __block CLLocationDegrees maxLon = -180, minLon = 180;

    [annotations enumerateObjectsUsingBlock:
     ^(id<MKAnnotation> annotation, NSUInteger idx, BOOL *stop) {
         CLLocationCoordinate2D coord = [annotation coordinate];
         maxLat = MAX(maxLat, coord.latitude);
         minLat = MIN(minLat, coord.latitude);
         maxLon = MAX(maxLon, coord.longitude);
         minLon = MIN(minLon, coord.longitude);
     }];

    CLLocationCoordinate2D center =
        CLLocationCoordinate2DMake((maxLat + minLat) / 2,
                                   (maxLon + minLon) / 2);
    MKCoordinateSpan span =
        MKCoordinateSpanMake((maxLat - minLat) / 2, (maxLon - minLon) / 2);

    return MKCoordinateRegionMake(center, span);
}

@end
