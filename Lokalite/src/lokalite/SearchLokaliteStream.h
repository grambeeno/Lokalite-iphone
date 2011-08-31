//
//  LokaliteSearchStream.h
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

typedef enum {
    LokaliteSearchStreamSearchEvents = 1,
    LokaliteSearchStreamSearchPlaces
} LokaliteSearchStreamSearchType;

@interface SearchLokaliteStream : LokaliteStream

@property (nonatomic, assign, readonly)
    LokaliteSearchStreamSearchType searchType;
@property (nonatomic, copy, readonly) NSString *keywords;
@property (nonatomic, copy, readonly) NSString *category;

#pragma mark - Initialization

- (id)initWithSearchStreamType:(LokaliteSearchStreamSearchType)type
                      keywords:(NSString *)keywords
                      category:(NSString *)category
                       baseUrl:(NSURL *)baseUrl
                       context:(NSManagedObjectContext *)context;

@end


@interface SearchLokaliteStream (InstantiationHelpers)

+ (id)eventSearchStreamWithKeywords:(NSString *)keywords
                           category:(NSString *)category
                            context:(NSManagedObjectContext *)context;
+ (id)placesSearchStreamWithKeywords:(NSString *)keywords
                            category:(NSString *)category
                             context:(NSManagedObjectContext *)context;

@end
