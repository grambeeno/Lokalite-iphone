//
//  Event+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Event.h"

@interface Event (GeneralHelpers)

+ (id)eventWithId:(NSNumber *)eventId inContext:(NSManagedObjectContext *)moc;

+ (NSArray *)eventObjectsFromJsonObjects:(NSDictionary *)jsonOjbects
                             withContext:(NSManagedObjectContext *)context;

+ (id)existingOrNewEventFromJsonData:(NSDictionary *)eventData
                           inContext:(NSManagedObjectContext *)context;

@end