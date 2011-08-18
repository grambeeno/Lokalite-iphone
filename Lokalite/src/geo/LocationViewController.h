//
//  LocationViewController.h
//  Lokalite
//
//  Created by John Debay on 8/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@protocol MappableLokaliteObject;

@interface LocationViewController : UIViewController <UIActionSheetDelegate>

@property (nonatomic, retain, readonly)
    id<MappableLokaliteObject> mappableObject;

#pragma mark - Initialization

- (id)initWithMappableLokaliteObject:(id<MappableLokaliteObject>)object;

@end
