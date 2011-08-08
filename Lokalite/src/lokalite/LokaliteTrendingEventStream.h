//
//  LokaliteTrendingEventStream.h
//  Lokalite
//
//  Created by John Debay on 8/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

@interface LokaliteTrendingEventStream : LokaliteStream

@end


@interface LokaliteTrendingEventStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context;

@end

