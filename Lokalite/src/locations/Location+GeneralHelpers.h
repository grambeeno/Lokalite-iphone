//
//  Location+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Location.h"

@interface Location (GeneralHelpers)

+ (id)existingOrNewLocationFromJsonData:(NSDictionary *)jsonData
                              inContext:(NSManagedObjectContext *)context;

@end
