//
//  EventMapViewController.m
//  Lokalite
//
//  Created by John Debay on 8/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventMapViewController.h"

#import "LokaliteObjectMapAnnotation.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

@implementation EventMapViewController

@synthesize delegate = delegate_;
@synthesize mapView = mapView_;
@synthesize annotations = annotations_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

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

    LokaliteObjectMapAnnotation *lokaliteAnnotation =
        (LokaliteObjectMapAnnotation *) annotation;
    id<LokaliteObject> lokaliteObject = [lokaliteAnnotation lokaliteObject];
    UIImage *image = [lokaliteObject image];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGRect imageViewFrame = [imageView frame];
    imageViewFrame.size = CGSizeMake(32, 32);
    [imageView setFrame:imageViewFrame];
    [view setLeftCalloutAccessoryView:imageView];
    [imageView release], imageView = nil;

    UIButton *button = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    [view setRightCalloutAccessoryView:button];

    return view;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
    calloutAccessoryControlTapped:(UIControl *)control
{
    LokaliteObjectMapAnnotation *annotation =
        (LokaliteObjectMapAnnotation *) [view annotation];
    id<LokaliteObject> object = [annotation lokaliteObject];

    [[self delegate] eventMapViewController:self didSelectObject:object];
}

#pragma mark - Accessors

- (void)setAnnotations:(NSArray *)annotations
{
    if (annotations_ != annotations) {
        if (annotations_) {
            [[self mapView] removeAnnotations:annotations_];
            [annotations_ release];
        }
        annotations_ = [annotations copy];

        MKCoordinateRegion region =
            [[self class] coordinateRegionForMapAnnotations:annotations_];
        [[self mapView] setRegion:region];

        [[self mapView] addAnnotations:annotations_];
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
        MKCoordinateSpanMake((maxLat - minLat), (maxLon - minLon));

    return MKCoordinateRegionMake(center, span);
}

@end
