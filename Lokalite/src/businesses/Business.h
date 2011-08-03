//
//  Business.h
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "LokaliteObject.h"

@class Category, Event;

@interface Business : NSManagedObject <LokaliteObject> {
@private
}
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) Category *category;
@end

@interface Business (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;
@end
