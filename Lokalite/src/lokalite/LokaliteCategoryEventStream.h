//
//  LokaliteCategoryEventStream.h
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

@interface LokaliteCategoryEventStream : LokaliteStream

@property (nonatomic, copy, readonly) NSString *categoryName;

#pragma mark - Initialization

- (id)initWithCategoryName:(NSString *)categoryName
                   baseUrl:(NSURL *)baseUrl
                   context:(NSManagedObjectContext *)context;

@end


@interface  LokaliteCategoryEventStream (InstantiationHelpers)

+ (id)streamWithCategoryName:(NSString *)categoryName
                     context:(NSManagedObjectContext *)context;

@end
