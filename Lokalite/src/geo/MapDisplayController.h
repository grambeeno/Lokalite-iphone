//
//  MapDisplayController.h
//  Lokalite
//
//  Created by John Debay on 8/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol MapDisplayControllerDelegate;

@interface MapDisplayController : NSObject <MKMapViewDelegate>

@property (nonatomic, assign)
    IBOutlet id<MapDisplayControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;

@property (nonatomic, assign) BOOL annotationsShowRightAccessoryView;

#pragma mark - Initialization

- (id)initWithMapView:(MKMapView *)mapView;

#pragma mark - Modifying annotations

//@property (nonatomic, copy) NSArray *annotations;

- (NSArray *)annotations;
- (void)setAnnotations:(NSArray *)annotations;
- (void)addAnnotations:(NSArray *)annotations;
- (void)removeAnnotations:(NSArray *)annotations;
- (void)removeAllAnnotations;

#pragma mark - Map geometry

+ (MKCoordinateRegion)coordinateRegionForMapAnnotations:(NSArray *)annotations;
+ (MKCoordinateRegion)boulderCoordinateRegion;

@end



@protocol MappableLokaliteObject;

@protocol MapDisplayControllerDelegate <NSObject>

- (void)mapDisplayController:(MapDisplayController *)controller
             didSelectObject:(id<MappableLokaliteObject>)object;
- (void)mapDisplayController:(MapDisplayController *)controller
              didSelectGroup:(NSArray *)group;

@end
