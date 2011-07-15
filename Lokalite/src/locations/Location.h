//
//  Location.h
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Venue;

@interface Location : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * formattedAddress;
@property (nonatomic, retain) NSNumber * latitude;
@property (nonatomic, retain) NSNumber * longitude;
@property (nonatomic, retain) NSSet *venues;
@end

@interface Location (CoreDataGeneratedAccessors)

- (void)addVenuesObject:(Venue *)value;
- (void)removeVenuesObject:(Venue *)value;
- (void)addVenues:(NSSet *)values;
- (void)removeVenues:(NSSet *)values;

@end
