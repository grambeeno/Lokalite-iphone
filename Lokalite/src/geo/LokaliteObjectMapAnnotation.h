//
//  EventMapAnnotation.h
//  Lokalite
//
//  Created by John Debay on 8/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@protocol LokaliteObject;

@interface LokaliteObjectMapAnnotation : NSObject <MKAnnotation>
{
    CLLocationCoordinate2D coordinate_;
    NSString *title_, *subtitle_;
}

@property (nonatomic, retain, readonly) id<LokaliteObject> lokaliteObject;

#pragma mark - Initialization

- (id)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                   title:(NSString *)title
                subtitle:(NSString *)subtitle
                  object:(id<LokaliteObject>)object;

@end
