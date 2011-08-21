//
//  LokaliteCategoryEventStream.h
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

typedef enum {
    LokaliteCategoryStreamEvents = 1,
    LokaliteCategoryStreamPlaces
} LokaliteCategoryStreamType;

@interface CategoryLokaliteStream : LokaliteStream

@property (nonatomic, copy, readonly) NSString *categoryName;
@property (nonatomic, assign, readonly) LokaliteCategoryStreamType streamType;
@property (nonatomic, copy) NSArray * (^parseBlock)(NSDictionary *jsonObjects);

#pragma mark - Initialization

- (id)initWithCategoryName:(NSString *)categoryName
                streamType:(LokaliteCategoryStreamType)streamType
                   baseUrl:(NSURL *)baseUrl
                   context:(NSManagedObjectContext *)context;

@end


@interface  CategoryLokaliteStream (InstantiationHelpers)

+ (id)eventStreamWithCategoryName:(NSString *)categoryName
                          context:(NSManagedObjectContext *)context;

+ (id)placeStreamWithCategoryName:(NSString *)categoryName
                          context:(NSManagedObjectContext *)context;

@end
