//
//  MapDisplayController.m
//  Lokalite
//
//  Created by John Debay on 8/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "MapDisplayController.h"

#import "LokaliteObjectMapAnnotation.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"


@interface MapDisplayController ()

#pragma mark - Managing the map view

- (void)zoomMapViewForAnnotations:(NSArray *)annotations;

@end



@implementation MapDisplayController

@synthesize delegate = delegate_;
@synthesize mapView = mapView_;

@synthesize annotationsShowRightAccessoryView =
    annotationsShowRightAccessoryView_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [mapView_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (void)initialize
{
    annotationsShowRightAccessoryView_ = YES;
}

- (id)initWithMapView:(MKMapView *)mapView
{
    self = [super init];
    if (self) {
        mapView_ = [mapView retain];
        [mapView_ setDelegate:self];

        [self initialize];
    }

    return self;
}

- (void)awakeFromNib
{
    [self initialize];
}

#pragma mark - Modifying annotations

- (NSArray *)annotations
{
    return [[self mapView] annotations];
}

- (void)setAnnotations:(NSArray *)annotations
{
    [self removeAllAnnotations];

    if (annotations) {
        [self addAnnotations:annotations];
        [self zoomMapViewForAnnotations:annotations];
    }
}

- (void)addAnnotations:(NSArray *)annotations
{
    [[self mapView] addAnnotations:annotations];
}

- (void)removeAnnotations:(NSArray *)annotations
{
    [[self mapView] removeAnnotations:annotations];
}

- (void)removeAllAnnotations
{
    [self removeAnnotations:[self annotations]];
}

#pragma mark - Managing the map view

- (void)zoomMapViewForAnnotations:(NSArray *)annotations
{
    MKCoordinateRegion region =
        [[self class] coordinateRegionForMapAnnotations:annotations];
    [[self mapView] setRegion:region];
}

#pragma mark - MKMapViewDelegate implmeentation

- (MKAnnotationView *)mapView:(MKMapView *)mapView
            viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([mapView userLocation] == annotation)
        return nil;

    static NSString *AnnotationId = @"MapAnnotation";
    MKPinAnnotationView *view = (MKPinAnnotationView *)
        [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationId];
    if (!view) {
        view = [[[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                reuseIdentifier:AnnotationId]
                autorelease];
        [view setAnimatesDrop:YES];
        [view setPinColor:MKPinAnnotationColorGreen];
        [view setCanShowCallout:YES];
    }

    LokaliteObjectMapAnnotation *lokaliteAnnotation =
        (LokaliteObjectMapAnnotation *) annotation;
    id<MappableLokaliteObject> lokaliteObject =
        [lokaliteAnnotation lokaliteObject];
    UIImage *image = [lokaliteObject mapAnnotationViewImage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    CGRect imageViewFrame = [imageView frame];
    imageViewFrame.size = CGSizeMake(32, 32);
    [imageView setFrame:imageViewFrame];
    [view setLeftCalloutAccessoryView:imageView];
    [imageView release], imageView = nil;

    UIButton *rightAccessoryView = nil;
    if ([self annotationsShowRightAccessoryView])
        rightAccessoryView =
            [UIButton buttonWithType:UIButtonTypeDetailDisclosure];

    [view setRightCalloutAccessoryView:rightAccessoryView];

    return view;
}

- (void)mapView:(MKMapView *)mapView
 annotationView:(MKAnnotationView *)view
    calloutAccessoryControlTapped:(UIControl *)control
{
    LokaliteObjectMapAnnotation *annotation =
        (LokaliteObjectMapAnnotation *) [view annotation];
    id<MappableLokaliteObject> object = [annotation lokaliteObject];

    [[self delegate] mapDisplayController:self didSelectObject:object];
}

#pragma mark - Accessors

/*
- (void)setAnnotations:(NSArray *)annotations
{
    if (annotations_ != annotations) {
        if (annotations_) {
            [[self mapView] removeAnnotations:annotations_];
            [annotations_ release];
        }
        annotations_ = [annotations copy];

        if (annotations_) {
            [[self mapView] addAnnotations:annotations_];

            MKCoordinateRegion region =
                [[self class] coordinateRegionForMapAnnotations:annotations_];
            [[self mapView] setRegion:region];
        }
    }
}
 */

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
        MKCoordinateSpanMake(maxLat - minLat, maxLon - minLon);

    return MKCoordinateRegionMake(center, span);
}

@end
