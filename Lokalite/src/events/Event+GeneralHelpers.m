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

#import "SDKAdditions.h"

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

    [event setBusiness:business];

    NSString *name = [eventData objectForKey:@"name"];
    [event setValueIfNecessary:name forKey:@"name"];

    NSString *startString = [eventData objectForKey:@"starts_at"];
    NSDate *startDate = [NSDate dateFromLokaliteServerString:startString];
    [event setValueIfNecessary:startDate forKey:@"startDate"];

    NSString *endString = [eventData objectForKey:@"ends_at"];
    NSDate *endDate = [NSDate dateFromLokaliteServerString:endString];
    [event setValueIfNecessary:endDate forKey:@"endDate"];

    NSString *summary = [eventData objectForKey:@"description"];
    [event setValueIfNecessary:summary forKey:@"summary"];

    NSDictionary *imageData =
        [[eventData objectForKey:@"image"] objectForKey:@"image"];
    if (imageData) {
        NSString *url = [imageData objectForKey:@"url"];
        if ([event setValueIfNecessary:url forKey:@"imageUrl"])
            [event setImageData:nil];
    }

    return event;
}

@end
