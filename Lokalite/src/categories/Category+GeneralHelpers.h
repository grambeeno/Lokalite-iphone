//
//  Category+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Category.h"

@class LokaliteDownloadSource;

@interface Category (GeneralHelpers)

+ (id)existingOrNewCategoryFromJsonData:(NSDictionary *)jsonData
                         downloadSource:(LokaliteDownloadSource *)source
                              inContext:(NSManagedObjectContext *)context;

@end
