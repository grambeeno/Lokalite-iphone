//
//  LokaliteSearchStream.h
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

@interface LokaliteSearchStream : LokaliteStream

@property (nonatomic, copy, readonly) NSString *keywords;

@property (nonatomic, assign) BOOL includeEvents;
@property (nonatomic, assign) BOOL includeBusinesses;

@end


@interface LokaliteSearchStream (InstantiationHelpers)

+ (id)streamWithKeywords:(NSString *)keywords
                 context:(NSManagedObjectContext *)context;

@end
