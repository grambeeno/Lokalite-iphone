//
//  LokaliteFeaturedEventStream.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "CategoryLokaliteStream.h"

@interface FeaturedEventLokaliteStream : CategoryLokaliteStream

@end


@interface FeaturedEventLokaliteStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context;

@end
