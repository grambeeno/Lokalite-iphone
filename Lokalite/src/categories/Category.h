//
//  Category.h
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Business, Event;

@interface Category : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSSet *businesses;
@end

@interface Category (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;
- (void)addBusinessesObject:(Business *)value;
- (void)removeBusinessesObject:(Business *)value;
- (void)addBusinesses:(NSSet *)values;
- (void)removeBusinesses:(NSSet *)values;
@end
