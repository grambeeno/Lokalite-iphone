//
//  CategoryFilter.h
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CategoryFilter : NSObject

@property (nonatomic, copy, readonly) NSNumber *categoryId;
@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *shortName;
@property (nonatomic, retain, readonly) UIImage *buttonImage;
@property (nonatomic, retain, readonly) UIImage *selectedButtonImage;

#pragma mark - Initialization

- (id)initWithCategoryId:(NSNumber *)categoryId
                    name:(NSString *)name
               shortName:(NSString *)shortName
             buttonImage:(UIImage *)buttonImage
     selectedButtonImage:(UIImage *)selectedButtonImage;

#pragma mark - Accessors

// The term sent to the server to retrieve objects that match this category
- (NSString *)serverFilter;

@end


@interface CategoryFilter (InstantiationHelpers)

+ (NSArray *)defaultEventFilters;
+ (NSArray *)defaultPlaceFilters;

+ (id)categoryFromPlistDictionary:(NSDictionary *)dictionary;

@end
