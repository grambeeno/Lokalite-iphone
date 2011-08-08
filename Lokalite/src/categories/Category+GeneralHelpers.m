//
//  Category+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Category+GeneralHelpers.h"

#import "LokaliteDownloadSource.h"

#import "SDKAdditions.h"

@implementation Category (GeneralHelpers)

+ (id)existingOrNewCategoriesFromJsonData:(NSArray *)jsonData
                           downloadSource:(LokaliteDownloadSource *)source
                                inContext:(NSManagedObjectContext *)context
{
    NSArray *categories =
        [jsonData arrayByMappingArray:
         ^(NSDictionary *categoryData, NSUInteger idx, BOOL *stop) {
            return [self existingOrNewCategoryFromJsonData:categoryData
                                            downloadSource:source
                                                 inContext:context];
        }];

    return categories;
}

+ (id)existingOrNewCategoryFromJsonData:(NSDictionary *)jsonData
                         downloadSource:(LokaliteDownloadSource *)source
                              inContext:(NSManagedObjectContext *)context
{
    NSNumber *identifier = [jsonData objectForKey:@"id"];
    Category *category = [Category instanceWithIdentifier:identifier
                                                inContext:context];
    if (!category) {
        category = [Category createInstanceInContext:context];
        [category setIdentifier:identifier];
    }

    [category addDownloadSourcesObject:source];

    NSString *name = [jsonData objectForKey:@"name"];
    [category setValueIfNecessary:name forKey:@"name"];

    return category;
}

@end
