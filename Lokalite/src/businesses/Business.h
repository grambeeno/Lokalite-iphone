//
//  Business.h
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Event;

@interface Business : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSSet *events;
@end

@interface Business (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

@end
