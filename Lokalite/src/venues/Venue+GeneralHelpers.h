//
//  Venue+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Venue.h"

@interface Venue (GeneralHelpers)

+ (id)existingOrNewVenueFromJsonData:(NSDictionary *)jsonData
                           inContext:(NSManagedObjectContext *)context;

@end
