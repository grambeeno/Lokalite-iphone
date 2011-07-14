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

    [event setName:[eventData objectForKey:@"name"]];

    NSString *startString = [eventData objectForKey:@"starts_at"];
    NSString *endString = [eventData objectForKey:@"ends_at"];
    [event setStartDate:[NSDate dateFromLokaliteServerString:startString]];
    [event setEndDate:[NSDate dateFromLokaliteServerString:endString]];

    [event setSummary:[eventData objectForKey:@"description"]];
    [event setBusiness:business];

    NSDictionary *imageData =
        [[eventData objectForKey:@"image"] objectForKey:@"image"];
    if (imageData) {
        NSString *url = [imageData objectForKey:@"url"];
        NSString *oldUrl = [event imageUrl];
        if (![oldUrl isEqualToString:url]) {
            [event setImageUrl:url];
            [event setImageData:nil];
        }
    }

    return event;
}

@end
