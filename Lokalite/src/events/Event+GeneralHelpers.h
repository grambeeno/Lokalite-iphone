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

#pragma mark - Object lifecycle

//
// Performs a delete and deletes the associated business if this is the only
// event still associated with its business.
//
- (void)deleteInContext:(NSManagedObjectContext *)context;

@end


@class CLLocation;

@interface Event (ConvenienceMethods)

//
// Convenience method that reaches through the Venue and the Location instance
// to get a CLLocation object.
//
- (CLLocation *)location;

@end
