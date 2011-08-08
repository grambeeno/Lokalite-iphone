//
//  LokaliteFeaturedEventStream.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

@interface LokaliteFeaturedEventStream : LokaliteStream

@end


@interface LokaliteFeaturedEventStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context;

@end
