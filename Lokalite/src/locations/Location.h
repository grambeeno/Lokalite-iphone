//
//  Location.h
//  Lokalite
//
//  Created by John Debay on 8/4/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LokaliteObject.h"

@class Venue;

@interface Location : LokaliteObject {
@private
}
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) NSSet *venues;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addVenuesObject:(Venue *)value;
- (void)removeVenuesObject:(Venue *)value;
- (void)addVenues:(NSSet *)values;
- (void)removeVenues:(NSSet *)values;
@end
