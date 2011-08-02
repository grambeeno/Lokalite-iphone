//
//  FeaturedEventsViewController.h
//  Lokalite
//
//  Created by John Debay on 7/27/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStreamViewController.h"
#import <MapKit/MapKit.h>

@class EventMapViewController;

@interface FeaturedEventsViewController : LokaliteStreamViewController

@property (nonatomic, retain) IBOutlet MKMapView *mapView;
@property (nonatomic, retain)
    IBOutlet EventMapViewController *mapViewController;

@end
