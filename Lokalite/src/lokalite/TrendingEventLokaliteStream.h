//
//  LokaliteTrendingEventStream.h
//  Lokalite
//
//  Created by John Debay on 8/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

@interface TrendingEventLokaliteStream : LokaliteStream

@end


@interface TrendingEventLokaliteStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context;

@end

