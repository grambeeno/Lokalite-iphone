//
//  GroupedMapAnnotation.h
//  Lokalite
//
//  Created by John Debay on 9/1/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface GroupedMapAnnotation : NSObject <MKAnnotation>

@property (nonatomic, copy, readonly) NSArray *annotations;

#pragma mark - Initialization

- (id)initWithAnnotation:(id<MKAnnotation>)annotation;
- (id)initWithAnnotations:(NSArray *)annotations;

#pragma mark - Manipulating annotations

- (void)addAnnotation:(id<MKAnnotation>)annotation;
- (void)removeAnnotation:(id<MKAnnotation>)annotation;

@end
