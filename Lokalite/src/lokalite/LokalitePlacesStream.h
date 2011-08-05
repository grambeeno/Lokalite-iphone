//
//  LokalitePlacesStream.h
//  Lokalite
//
//  Created by John Debay on 7/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

@interface LokalitePlacesStream : LokaliteStream

@end


@interface LokalitePlacesStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context;

@end
