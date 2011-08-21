//
//  LokalitePlacesStream.h
//  Lokalite
//
//  Created by John Debay on 7/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

@interface PlacesLokaliteStream : LokaliteStream

@end


@interface PlacesLokaliteStream (InstantiationHelpers)

+ (id)streamWithContext:(NSManagedObjectContext *)context;

@end
