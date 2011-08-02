//
//  EventMapViewController.h
//  Lokalite
//
//  Created by John Debay on 8/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol EventMapViewControllerDelegate;

@interface EventMapViewController : NSObject <MKMapViewDelegate>

@property (nonatomic, assign) id<EventMapViewControllerDelegate> delegate;

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, copy) NSArray *annotations;

#pragma mark - Map geometry

+ (MKCoordinateRegion)coordinateRegionForMapAnnotations:(NSArray *)annotations;

@end



@class Event;

@protocol EventMapViewControllerDelegate <NSObject>

- (void)eventMapViewController:(EventMapViewController *)controller
                didSelectEvent:(Event *)event;

@end
