//
//  Category+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Category.h"

@interface Category (GeneralHelpers)

+ (id)existingOrNewCategoryFromJsonData:(NSDictionary *)jsonData
                              inContext:(NSManagedObjectContext *)context;

@end
