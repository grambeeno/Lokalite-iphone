//
//  Business.h
//  Lokalite
//
//  Created by John Debay on 8/8/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LokaliteObject.h"

@class Category, Event, Location;

@interface Business : LokaliteObject {
@private
}
@property (nonatomic, retain) NSString * status;
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * email;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) Location *location;
@end

@interface Business (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;
- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;
@end
