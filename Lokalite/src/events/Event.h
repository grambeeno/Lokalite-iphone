//
//  Event.h
//  Lokalite
//
//  Created by John Debay on 8/15/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "LokaliteObject.h"
#import "MappableLokaliteObject.h"
#import "ShareableObject.h"

@class Business, Category, Location;

@interface Event : LokaliteObject <MappableLokaliteObject, ShareableObject> {
@private
}
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * dateDescription;
@property (nonatomic, retain) NSNumber * trended;
@property (nonatomic, retain) NSNumber * featured;
@property (nonatomic, retain) NSNumber * usersCount;
@property (nonatomic, retain) NSString * fullImageUrl;
@property (nonatomic, retain) NSData * fullImageData;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * distance;
@property (nonatomic, retain) NSString * largeImageUrl;
@property (nonatomic, retain) NSString * thumbnailImageUrl;
@property (nonatomic, retain) NSString * mediumImageUrl;
@property (nonatomic, retain) NSString * smallImageUrl;
@property (nonatomic, retain) NSData * thumbnailImageData;
@property (nonatomic, retain) NSData * largeImageData;
@property (nonatomic, retain) NSData * mediumImageData;
@property (nonatomic, retain) NSData * smallImageData;
@property (nonatomic, retain) Location *location;
@property (nonatomic, retain) NSSet *categories;
@property (nonatomic, retain) Business *business;
@end

@interface Event (CoreDataGeneratedAccessors)

- (void)addCategoriesObject:(Category *)value;
- (void)removeCategoriesObject:(Category *)value;
- (void)addCategories:(NSSet *)values;
- (void)removeCategories:(NSSet *)values;
@end
