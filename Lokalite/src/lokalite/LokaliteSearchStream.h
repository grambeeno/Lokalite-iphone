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

@interface LokaliteSearchStream : LokaliteStream

@property (nonatomic, assign, readonly)
    LokaliteSearchStreamSearchType searchType;
@property (nonatomic, copy, readonly) NSString *keywords;

#pragma mark - Initialization

- (id)initWithSearchStreamType:(LokaliteSearchStreamSearchType)type
                      keywords:(NSString *)keywords
                       baseUrl:(NSURL *)baseUrl
                       context:(NSManagedObjectContext *)context;

@end


@interface LokaliteSearchStream (InstantiationHelpers)

+ (id)eventSearchStreamWithKeywords:(NSString *)keywords
                            context:(NSManagedObjectContext *)context;
+ (id)placesSearchStreamWithKeywords:(NSString *)keywords
                             context:(NSManagedObjectContext *)context;

@end
