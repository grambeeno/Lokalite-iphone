//
//  Location.h
//  Lokalite
//
//  Created by John Debay on 8/8/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LokaliteObject.h"

@class Business, Event;

@interface Location : LokaliteObject {
@private
}
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSSet *businesses;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;
- (void)addBusinessesObject:(Business *)value;
- (void)removeBusinessesObject:(Business *)value;
- (void)addBusinesses:(NSSet *)values;
- (void)removeBusinesses:(NSSet *)values;
@end
