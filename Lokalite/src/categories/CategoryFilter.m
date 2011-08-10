//
//  CategoryFilter.m
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "CategoryFilter.h"

@implementation CategoryFilter

@synthesize categoryId = categoryId_;
@synthesize name = name_;
@synthesize shortName = shortName_;
@synthesize buttonImage = buttonImage_;
@synthesize selectedButtonImage = selectedButtonImage_;

#pragma mark - Memory management

- (void)dealloc
{
    [categoryId_ release];
    [name_ release];
    [shortName_ release];
    [buttonImage_ release];
    [selectedButtonImage_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithCategoryId:(NSNumber *)categoryId
                    name:(NSString *)name
               shortName:(NSString *)shortName
             buttonImage:(UIImage *)buttonImage
     selectedButtonImage:(UIImage *)selectedButtonImage
{
    self = [super init];
    if (self) {
        categoryId_ = [categoryId copy];
        name_ = [name copy];
        shortName_ = [shortName copy];
        buttonImage_ = [buttonImage retain];
        selectedButtonImage_ = [selectedButtonImage retain];
    }

    return self;
}

#pragma mark - Accessors

- (NSString *)serverFilter
{
    return [self name];
}

@end


@implementation CategoryFilter (InstantiationHelpers)

+ (NSArray *)categoryFiltersFromPlistFile:(NSString *)fileName
{
    NSString *file = [[NSBundle mainBundle] pathForResource:fileName
                                                     ofType:@"plist"];

    NSArray *filterData = [NSArray arrayWithContentsOfFile:file];

    NSMutableArray *filters =
        [NSMutableArray arrayWithCapacity:[filterData count]];
    [filterData enumerateObjectsUsingBlock:
     ^(NSDictionary *dictionary, NSUInteger idx, BOOL *stop) {
        CategoryFilter *filter =
            [CategoryFilter categoryFromPlistDictionary:dictionary];
         [filters addObject:filter];
     }];

    return filters;
}

+ (NSArray *)defaultEventFilters
{
    return [self categoryFiltersFromPlistFile:@"category-filters-events"];
}

+ (NSArray *)defaultPlaceFilters
{
    return [self categoryFiltersFromPlistFile:@"category-filters-places"];
}

+ (id)categoryFromPlistDictionary:(NSDictionary *)dictionary
{
    NSNumber *identifier = [dictionary objectForKey:@"identifier"];
    NSString *name = [dictionary objectForKey:@"name"];
    NSString *shortName = [dictionary objectForKey:@"short-name"];
    NSString *imageName = [dictionary objectForKey:@"image"];
    NSString *selectedImageName = [dictionary objectForKey:@"image-selected"];

    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *selectedImage = [UIImage imageNamed:selectedImageName];

    return [[[self alloc] initWithCategoryId:identifier
                                        name:name
                                   shortName:shortName
                                 buttonImage:image
                         selectedButtonImage:selectedImage] autorelease];
}

@end
