//
//  CategoryFilter.h
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface CategoryFilter : NSObject

@property (nonatomic, copy, readonly) NSString *name;
@property (nonatomic, copy, readonly) NSString *shortName;
@property (nonatomic, retain, readonly) UIImage *buttonImage;

#pragma mark - Initialization

- (id)initWithName:(NSString *)name
         shortName:(NSString *)shortName
       buttonImage:(UIImage *)buttonImage;

@end


@interface CategoryFilter (InstantiationHelpers)

+ (NSArray *)defaultFilters;
+ (id)categoryFromPlistDictionary:(NSDictionary *)dictionary;

@end
