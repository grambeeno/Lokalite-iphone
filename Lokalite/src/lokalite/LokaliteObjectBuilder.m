//
//  LokaliteObjectBuilder.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteObjectBuilder.h"

#import "Business.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "SDKAdditions.h"

#import <CoreData/CoreData.h>

@implementation LokaliteObjectBuilder

+ (NSArray *)replaceEventsInContext:(NSManagedObjectContext *)context
             withObjectsInJsonArray:(NSArray *)jsonObjects
{
    NSArray *eventArray = [Event findAllInContext:context];
    NSMutableDictionary *existingEvents =
        [NSMutableDictionary dictionaryWithCapacity:[eventArray count]];
    [eventArray enumerateObjectsUsingBlock:
     ^(Event *event, NSUInteger idx, BOOL *stop) {
        [existingEvents setObject:event forKey:[event identifier]];
     }];

    NSMutableArray *events =
        [NSMutableArray arrayWithCapacity:[jsonObjects count]];
    [jsonObjects enumerateObjectsUsingBlock:
     ^(NSDictionary *eventData, NSUInteger idx, BOOL *stop) {
         Event *event = [Event existingOrNewEventFromJsonData:eventData
                                              inContext:context];
         [events addObject:event];
         [existingEvents removeObjectForKey:[event identifier]];
     }];

    [existingEvents enumerateKeysAndObjectsUsingBlock:
     ^(NSNumber *identifier, Event *event, BOOL *stop) {
        NSLog(@"Deleting event: %@: %@", identifier, [event name]);
        [event deleteInContext:context];
    }];

    return events;
}

@end
