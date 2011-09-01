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

@property (nonatomic, retain) NSMutableDictionary *allAnnotations;

#pragma mark - Managing the map view

- (void)zoomMapViewForAnnotations:(NSArray *)annotations;

@end


@implementation MapDisplayController

@synthesize delegate = delegate_;
@synthesize mapView = mapView_;

@synthesize annotationsShowRightAccessoryView =
    annotationsShowRightAccessoryView_;

@synthesize allAnnotations = allAnnotations_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [mapView_ release];
    [allAnnotations_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (void)initialize
{
    annotationsShowRightAccessoryView_ = YES;
    allAnnotations_ = [[NSMutableDictionary alloc] init];

    [[self mapView] setRegion:[[self class] boulderCoordinateRegion]];
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

    if ([annotations count]) {
        [self addAnnotations:annotations];
        [self zoomMapViewForAnnotations:annotations];
    }
}

+ (NSString *)keyForCoordinate:(CLLocationCoordinate2D)coord
{
    return [NSString
            stringWithFormat:@"%f %f", coord.latitude, coord.longitude];
}

- (NSArray *)addNewAnnotationsToExistingAnnotations:(NSArray *)annotations
{
    NSMutableArray *newAnnotations =
        [NSMutableArray arrayWithCapacity:[annotations count]];

    NSMutableDictionary *allAnnotations = [self allAnnotations];
    [annotations enumerateObjectsUsingBlock:
     ^(id<MKAnnotation> annotation, NSUInteger idx, BOOL *stop) {
         CLLocationCoordinate2D coord = [annotation coordinate];
         NSString *coordKey = [[self class] keyForCoordinate:coord];
         NSMutableArray *existing = [allAnnotations objectForKey:coordKey];
         if (!existing) {
             existing = [NSMutableArray array];
             [allAnnotations setObject:existing forKey:coordKey];
             [newAnnotations addObject:annotation];
         }
         [existing addObject:annotation];
    }];

    return newAnnotations;
}

- (NSArray *)removeAnnotationsFromExistingAnnotations:(NSArray *)annotations
{
    NSMutableArray *oldAnnotations =
        [NSMutableArray arrayWithCapacity:[annotations count]];

    NSMutableDictionary *allAnnotations = [self allAnnotations];
    [annotations enumerateObjectsUsingBlock:
     ^(id<MKAnnotation> annotation, NSUInteger idx, BOOL *stop) {
         CLLocationCoordinate2D coord = [annotation coordinate];
         NSString *coordKey = [[self class] keyForCoordinate:coord];
         NSMutableArray *existing = [allAnnotations objectForKey:coordKey];
         [existing removeObject:annotation];
         if ([existing count] == 0) {
             [allAnnotations removeObjectForKey:coordKey];
             [oldAnnotations addObject:annotation];
         }
    }];

    return oldAnnotations;
}

- (void)addAnnotations:(NSArray *)annotations
{
    NSArray *newAnnotations =
        [self addNewAnnotationsToExistingAnnotations:annotations];
    [[self mapView] addAnnotations:newAnnotations];

}

- (void)removeAnnotations:(NSArray *)annotations
{
    NSArray *oldAnnotations =
        [self removeAnnotationsFromExistingAnnotations:annotations];
    [[self mapView] removeAnnotations:oldAnnotations];
}

- (void)removeAllAnnotations
{
    [self removeAnnotations:[self annotations]];
    [[self allAnnotations] removeAllObjects];
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

+ (MKCoordinateRegion)boulderCoordinateRegion
{
    CLLocationCoordinate2D center =
        CLLocationCoordinate2DMake(40.014785766601562, -105.26535034179688);
    MKCoordinateSpan span =
        MKCoordinateSpanMake(0.01428985595703125, 0.0293731689453125);

    return MKCoordinateRegionMake(center, span);
}

@end
