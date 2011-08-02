//
//  EventMapAnnotation.h
//  Lokalite
//
//  Created by John Debay on 8/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@class Event;

@interface EventMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, retain, readonly) Event *event;

#pragma mark - Initialization

- (id)initWithEvent:(Event *)event;

@end
