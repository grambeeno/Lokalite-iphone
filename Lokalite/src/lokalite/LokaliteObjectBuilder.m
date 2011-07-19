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

+ (NSArray *)createOrUpdateEventsInJsonArray:(NSArray *)jsonObjects
                                   inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *events =
        [NSMutableArray arrayWithCapacity:[jsonObjects count]];
    [jsonObjects enumerateObjectsUsingBlock:
     ^(NSDictionary *eventData, NSUInteger idx, BOOL *stop) {
         Event *event = [Event createOrUpdateEventFromJsonData:eventData
                                                     inContext:context];
         [events addObject:event];
     }];

    return events;
}

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
         Event *event = [Event createOrUpdateEventFromJsonData:eventData
                                                     inContext:context];
         [events addObject:event];
         [existingEvents removeObjectForKey:[event identifier]];
     }];

    [existingEvents enumerateKeysAndObjectsUsingBlock:
     ^(NSNumber *identifier, Event *event, BOOL *stop) {
        NSLog(@"Deleting event: %@: %@", identifier, [event name]);
        [context deleteObject:event];
    }];

    return events;
}

@end


@implementation LokaliteObjectBuilder (GeneralHelpers)

+ (void)replaceLokaliteObjects:(NSArray *)original
                   withObjects:(NSArray *)replacement
               usingValueOfKey:(NSString *)key
              remainingHandler:(void (^)(id remainingObject))handler
{
    NSMutableDictionary *remaining =
        [NSMutableDictionary dictionaryWithCapacity:[original count]];
    [original enumerateObjectsUsingBlock:
     ^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
         id value = [obj valueForKey:key];
         [remaining setObject:obj forKey:value];
     }];

    [replacement enumerateObjectsUsingBlock:
     ^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
         id value = [obj valueForKey:key];
         [remaining removeObjectForKey:value];
    }];

    [remaining enumerateKeysAndObjectsUsingBlock:
     ^(id key, id obj, BOOL *stop) {
         handler(obj);
     }];
}

@end


@implementation NSArray (LokaliteHelpers)

- (NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)replacement
                                 passingTest:(BOOL (^)(id obj))predicate
{
    NSIndexSet *indexes =
        [self indexesOfObjectsPassingTest:
         ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
             return predicate(obj);
         }];

    NSMutableArray *a = [[self mutableCopy] autorelease];
    [a removeObjectsAtIndexes:indexes];

    return a;
}

@end
