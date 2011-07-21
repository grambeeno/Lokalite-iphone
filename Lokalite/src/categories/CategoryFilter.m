//
//  CategoryFilter.m
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "CategoryFilter.h"

@implementation CategoryFilter

@synthesize name = name_;
@synthesize shortName = shortName_;
@synthesize buttonImage = buttonImage_;

#pragma mark - Initialization

- (id)initWithName:(NSString *)name
         shortName:(NSString *)shortName
       buttonImage:(UIImage *)buttonImage
{
    self = [super init];
    if (self) {
        name_ = [name copy];
        shortName_ = [shortName copy];
        buttonImage_ = [buttonImage retain];
    }

    return self;
}

@end


@implementation CategoryFilter (InstantiationHelpers)

+ (NSArray *)defaultFilters
{
    NSString *file = [[NSBundle mainBundle] pathForResource:@"category-filters"
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

+ (id)categoryFromPlistDictionary:(NSDictionary *)dictionary
{
    NSString *name = [dictionary objectForKey:@"name"];
    NSString *shortName = [dictionary objectForKey:@"short-name"];
    NSString *imageName = [dictionary objectForKey:@"image"];
    UIImage *image = [UIImage imageNamed:imageName];

    return [[[self alloc] initWithName:name
                             shortName:shortName
                           buttonImage:image] autorelease];
}

@end
