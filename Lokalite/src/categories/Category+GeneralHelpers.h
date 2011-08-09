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

#pragma mark - Lifecycle

//
// Delete the receiver if all of its relationships are empty.
//
- (BOOL)deleteIfAppropriate;

#pragma mark - Creating and finding instances

+ (id)existingOrNewCategoriesFromJsonData:(NSArray *)jsonData
                           downloadSource:(LokaliteDownloadSource *)source
                                inContext:(NSManagedObjectContext *)context;

+ (id)existingOrNewCategoryFromJsonData:(NSDictionary *)jsonData
                         downloadSource:(LokaliteDownloadSource *)source
                              inContext:(NSManagedObjectContext *)context;

@end
