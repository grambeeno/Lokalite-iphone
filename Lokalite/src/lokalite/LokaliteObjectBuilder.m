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

#import <CoreData/CoreData.h>

@implementation LokaliteObjectBuilder

+ (NSArray *)buildEventsFromJsonArray:(NSArray *)jsonObjects
                            inContext:(NSManagedObjectContext *)context
{
    NSMutableArray *events =
        [NSMutableArray arrayWithCapacity:[jsonObjects count]];
    [jsonObjects enumerateObjectsUsingBlock:
     ^(NSDictionary *eventData, NSUInteger idx, BOOL *stop) {
         Event *event = [Event existingOrNewEventFromJsonData:eventData
                                              inContext:context];
         [events addObject:event];
     }];

    return events;
}

@end
