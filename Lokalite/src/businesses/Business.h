//
//  Business.h
//  Lokalite
//
//  Created by John Debay on 8/15/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LokaliteObject.h"
#import "ShareableObject.h"

#import "MappableLokaliteObject.h"

@class Category, Event, Location;

@interface Business : LokaliteObject <MappableLokaliteObject, ShareableObject> {
@private
}
@property (nonatomic, retain) NSString * phone;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSString * fullImageUrl;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSData * fullImageData;
@property (nonatomic, retain) NSString * largeImageUrl;
@property (nonatomic, retain) NSData * largeImageData;
@property (nonatomic, retain) NSString * mediumImageUrl;
@property (nonatomic, retain) NSData * mediumImageData;
@property (nonatomic, retain) NSString * smallImageUrl;
@property (nonatomic, retain) NSData * smallImageData;
@property (nonatomic, retain) NSString * thumbnailImageUrl;
@property (nonatomic, retain) NSData * thumbnailImageData;
@property (nonatomic, retain) NSSet *events;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) Location *location;
@end

@interface Business (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;
- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;
@end
