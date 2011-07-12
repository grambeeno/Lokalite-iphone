//
//  Event+MockDataHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Event+MockDataHelpers.h"

#import "Business.h"
#import "Business+MockDataHelpers.h"

#import "NSManagedObject+GeneralHelpers.h"

@implementation Event (MockDataHelpers)

//+ (NSArray *)generateMockFeaturedEventsInContext:(NSManagedObjectContext *)moc
//{
//    NSMutableArray *events = [NSMutableArray array];
//
//    /*
//    Business *business = nil;
//    Event *event = nil;
//    NSPredicate *pred = nil;
//
//    pred = [NSPredicate predicateWithFormat:@"name == %@", @"Big City Burrito"];
//    business = [Business findFirstWithPredicate:pred inContext:moc];
//    event = [Event createInstanceInContext:moc];
//    [event setName:@"Fat Tuesday"];
//    [event setDate:[NSDate date]];
//    [event setSummary:@"Come in every Tuesday for FAT TUESDAY!"];
//    [event setBusiness:business];
//    [events addObject:event];
//    
//    pred = [NSPredicate predicateWithFormat:@"name == %@", @"Big City Burrito"];
//    business = [Business findFirstWithPredicate:pred inContext:moc];
//    event = [Event createInstanceInContext:moc];
//    [event setName:@"OZ Mania"];
//    [event setDate:[NSDate date]];
//    [event setSummary:@"Every Weekday any strain is $199 for an ounce (mix up to 2 strains)."];
//    [event setBusiness:business];
//    [events addObject:event];
//    
//    pred = [NSPredicate predicateWithFormat:@"name == %@", @"Big City Burrito"];
//    business = [Business findFirstWithPredicate:pred inContext:moc];
//    event = [Event createInstanceInContext:moc];
//    [event setName:@"Fat Tuesday"];
//    [event setDate:[NSDate date]];
//    [event setSummary:@""];
//    [event setBusiness:business];
//    [events addObject:event];
//    
//    pred = [NSPredicate predicateWithFormat:@"name == %@", @"Big City Burrito"];
//    business = [Business findFirstWithPredicate:pred inContext:moc];
//    event = [Event createInstanceInContext:moc];
//    [event setName:@"Fat Tuesday"];
//    [event setDate:[NSDate date]];
//    [event setSummary:@""];
//    [event setBusiness:business];
//    [events addObject:event];
//    
//    pred = [NSPredicate predicateWithFormat:@"name == %@", @"Big City Burrito"];
//    business = [Business findFirstWithPredicate:pred inContext:moc];
//    event = [Event createInstanceInContext:moc];
//    [event setName:@"Fat Tuesday"];
//    [event setDate:[NSDate date]];
//    [event setSummary:@""];
//    [event setBusiness:business];
//    [events addObject:event];
//    
//    pred = [NSPredicate predicateWithFormat:@"name == %@", @"Big City Burrito"];
//    business = [Business findFirstWithPredicate:pred inContext:moc];
//    event = [Event createInstanceInContext:moc];
//    [event setName:@"Fat Tuesday"];
//    [event setDate:[NSDate date]];
//    [event setSummary:@""];
//    [event setBusiness:business];
//    [events addObject:event];
//    
//    pred = [NSPredicate predicateWithFormat:@"name == %@", @"Big City Burrito"];
//    business = [Business findFirstWithPredicate:pred inContext:moc];
//    event = [Event createInstanceInContext:moc];
//    [event setName:@"Fat Tuesday"];
//    [event setDate:[NSDate date]];
//    [event setSummary:@""];
//    [event setBusiness:business];
//    [events addObject:event];
//     */
//
//    return events;
//}
//
//+ (NSArray *)mockFeaturedEventsInContext:(NSManagedObjectContext *)context
//{
//    NSArray *events = [self findAllInContext:nil];
//    return [events count] == 0 ? [self generateMockFeaturedEvents] : events;
//}

@end
