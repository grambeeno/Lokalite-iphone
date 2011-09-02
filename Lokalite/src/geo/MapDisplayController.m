//
//  MapDisplayController.m
//  Lokalite
//
//  Created by John Debay on 8/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "MapDisplayController.h"

#import "LokaliteObjectMapAnnotation.h"
#import "GroupedMapAnnotation.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "NSArray+GeneralHelpers.h"

@interface MapDisplayController ()

@property (nonatomic, retain) NSMutableDictionary *allAnnotations;

#pragma mark - Managing the map view

- (void)zoomMapViewForAnnotations:(NSArray *)annotations;

#pragma mark - Map annotation helpers

- (NSArray *)addNewAnnotationsToExistingAnnotations:(NSArray *)annotations;
- (NSArray *)removeAnnotationsFromExistingAnnotations:(NSArray *)annotations;
+ (NSString *)keyForCoordinate:(CLLocationCoordinate2D)coord;

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
    [[self mapView] removeAnnotations:[[self mapView] annotations]];
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

    GroupedMapAnnotation *groupedAnnotation =
        (GroupedMapAnnotation *) annotation;
    LokaliteObjectMapAnnotation *lokaliteAnnotation =
        [[groupedAnnotation annotations] objectAtIndex:0];
    id<MappableLokaliteObject> lokaliteObject =
        [lokaliteAnnotation lokaliteObject];
    UIImage *image = [lokaliteObject mapAnnotationViewImage];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
    [imageView setContentMode:UIViewContentModeScaleAspectFill];
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
    GroupedMapAnnotation *groupedAnnotation =
        (GroupedMapAnnotation *) [view annotation];
    NSArray *annotations = [groupedAnnotation annotations];
    if ([annotations count] == 1) {
        LokaliteObjectMapAnnotation *annotation = [annotations lastObject];
        [[self delegate] mapDisplayController:self
                              didSelectObject:[annotation lokaliteObject]];
    } else {
        NSArray *objects =
        [annotations arrayByMappingArray:
         ^(LokaliteObjectMapAnnotation *a, NSUInteger idx, BOOL *stop) {
            return [a lokaliteObject];
         }];
        [[self delegate] mapDisplayController:self didSelectGroup:objects];
    }
}

#pragma mark - Map annotation helpers

- (NSArray *)addNewAnnotationsToExistingAnnotations:(NSArray *)annotations
{
    NSMutableArray *newAnnotations =
        [NSMutableArray arrayWithCapacity:[annotations count]];

    NSMutableDictionary *allAnnotations = [self allAnnotations];
    [annotations enumerateObjectsUsingBlock:
     ^(id<MKAnnotation> annotation, NSUInteger idx, BOOL *stop) {
         CLLocationCoordinate2D coord = [annotation coordinate];
         NSString *coordKey = [[self class] keyForCoordinate:coord];

         GroupedMapAnnotation *groupedAnnotation =
            [allAnnotations objectForKey:coordKey];
         if (groupedAnnotation)
             [groupedAnnotation addAnnotation:annotation];
         else {
             groupedAnnotation =
                 [[GroupedMapAnnotation alloc] initWithAnnotation:annotation];
             [allAnnotations setObject:groupedAnnotation forKey:coordKey];
             [newAnnotations addObject:groupedAnnotation];
             [groupedAnnotation release], groupedAnnotation = nil;
         }
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

         GroupedMapAnnotation *groupedAnnotation =
            [allAnnotations objectForKey:coordKey];
         [groupedAnnotation removeAnnotation:annotation];
         if ([[groupedAnnotation annotations] count] == 0) {
             [oldAnnotations addObject:groupedAnnotation];
             [allAnnotations removeObjectForKey:coordKey];
         }
    }];

    return oldAnnotations;
}

+ (NSString *)keyForCoordinate:(CLLocationCoordinate2D)coord
{
    CLLocationDegrees latitutde = coord.latitude, longitude = coord.longitude;
    return [NSString stringWithFormat:@"%f %f", latitutde, longitude];
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
