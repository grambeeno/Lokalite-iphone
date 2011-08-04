//
//  Category+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Category+GeneralHelpers.h"

#import "SDKAdditions.h"

@implementation Category (GeneralHelpers)

+ (id)existingOrNewCategoryFromJsonData:(NSDictionary *)jsonData
                              inContext:(NSManagedObjectContext *)context
{
    NSNumber *identifier = [jsonData objectForKey:@"id"];
    Category *category = [Category instanceWithIdentifier:identifier
                                                inContext:context];
    if (!category) {
        category = [Category createInstanceInContext:context];
        [category setIdentifier:identifier];
    }

    [category setLastUpdated:[NSDate date]];

    NSString *name = [jsonData objectForKey:@"name"];
    [category setValueIfNecessary:name forKey:@"name"];

    return category;
}

@end
