//
//  Event+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Event+GeneralHelpers.h"

#import "LokaliteObjectBuilder.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"

#import "NSManagedObject+GeneralHelpers.h"

@implementation Event (GeneralHelpers)

+ (id)eventWithId:(NSNumber *)eventId inContext:(NSManagedObjectContext *)moc
{
    NSPredicate *pred =
        [NSPredicate predicateWithFormat:@"identifier == %@", eventId];
    return [self findFirstWithPredicate:pred inContext:moc];
}

+ (NSArray *)eventObjectsFromJsonObjects:(NSDictionary *)jsonOjbects
                             withContext:(NSManagedObjectContext *)context
{
    NSArray *objs = [[jsonOjbects objectForKey:@"data"] objectForKey:@"list"];
    NSArray *events = [LokaliteObjectBuilder buildEventsFromJsonArray:objs
                                                            inContext:context];

    return events;
}

+ (id)existingOrNewEventFromJsonData:(NSDictionary *)eventData
                           inContext:(NSManagedObjectContext *)context
{
    NSDictionary *bData = [eventData objectForKey:@"organization"];
    Business *business = [Business existingOrNewBusinessFromJsonData:bData
                                                           inContext:context];

    NSNumber *eventId = [eventData objectForKey:@"id"];
    Event *event = [self eventWithId:eventId inContext:context];
    if (!event) {
        event = [self createInstanceInContext:context];
        [event setIdentifier:eventId];
    }

    [event setName:[eventData objectForKey:@"name"]];
    [event setDate:[NSDate date]];
    [event setSummary:[eventData objectForKey:@"description"]];
    [event setBusiness:business];

    return event;
}

@end
