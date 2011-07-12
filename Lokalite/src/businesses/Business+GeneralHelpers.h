//
//  Business+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Business.h"

@interface Business (GeneralHelpers)

+ (id)businessWithId:(NSNumber *)businessId
           inContext:(NSManagedObjectContext *)context;

+ (id)existingOrNewBusinessFromJsonData:(NSDictionary *)businessData
                              inContext:(NSManagedObjectContext *)context;

@end