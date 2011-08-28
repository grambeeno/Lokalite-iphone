//
//  NSDate+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NSDate+GeneralHelpers.h"

@implementation NSDate (GeneralHelpers)

+ (id)dateFromLokaliteServerString:(NSString *)string
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        NSLocale *enUSPOSIXLocale =
            [[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]
             autorelease];

        [formatter setLocale:enUSPOSIXLocale];
        [formatter setDateFormat:@"yyyy'/'MM'/'dd HH':'mm':'ss ZZZZ"];
        [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    }

    return [formatter dateFromString:string];
}

- (NSString *)timeString
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }

    return [formatter stringFromDate:self];
}

- (BOOL)isToday
{
    NSDate *today = [[NSDate alloc] init];
    BOOL isToday = [self isOnSameDayAsDate:today];
    [today release], today = nil;

    return isToday;
}

- (BOOL)isTomorrow
{
    NSDate *tomorrow =
        [[NSDate alloc] initWithTimeIntervalSinceNow:60 * 60 * 24];
    BOOL isTomorrow = [self isOnSameDayAsDate:tomorrow];
    [tomorrow release], tomorrow = nil;

    return isTomorrow;
}

- (BOOL)isThisWeek
{
    NSDate *today = [[NSDate alloc] init];
    NSCalendar *calendar = [NSCalendar currentCalendar];

    // Get the weekday component of the current date
    NSDateComponents *weekdayComponents =
        [calendar components:NSWeekdayCalendarUnit fromDate:today];

    NSDateComponents *componentsToSubtract = [[NSDateComponents alloc] init];
    [componentsToSubtract setDay:0 - ([weekdayComponents weekday] - 1)];
 
    NSDate *beginningOfWeek =
        [calendar dateByAddingComponents:componentsToSubtract
                                  toDate:today
                                 options:0];

    // set beginningOfWeek to midnigth
    NSDateComponents *components =
        [calendar components:(NSYearCalendarUnit |
                              NSMonthCalendarUnit |
                              NSDayCalendarUnit)
                    fromDate:beginningOfWeek];
    beginningOfWeek = [calendar dateFromComponents:components];

    NSDate *endOfWeek =
        [beginningOfWeek dateByAddingTimeInterval:60 * 60 * 24 * 7];

    NSComparisonResult result = [beginningOfWeek compare:self];
    BOOL isAfterBeginningOfWeek =
        result == NSOrderedAscending || result == NSOrderedSame;
    result = [endOfWeek compare:self];
    BOOL isBeforeEndOfWeek =
        result == NSOrderedDescending || result == NSOrderedSame;

    [today release], today = nil;
    [componentsToSubtract release], componentsToSubtract = nil;
 
    return isAfterBeginningOfWeek && isBeforeEndOfWeek;
}

- (BOOL)isMoreThanWeekInTheFuture
{
    NSCalendar * currentCalendar = [NSCalendar currentCalendar];

    unsigned unitFlags =
        NSYearCalendarUnit | NSMonthCalendarUnit |  NSDayCalendarUnit;

    NSDateComponents * selfComps =
        [currentCalendar components:unitFlags fromDate:self];

    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setDay:[selfComps day]];
    [comps setMonth:[selfComps month]];
    [comps setYear:[selfComps year]];

    NSDate * beginningOfToday = [currentCalendar dateFromComponents:comps];
    [comps release], comps = nil;

    return [beginningOfToday timeIntervalSinceNow] < 60 * 60 * 24 * 7;
}

- (NSInteger)daysUntilDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSInteger startDay = [calendar ordinalityOfUnit:NSDayCalendarUnit
                                             inUnit:NSEraCalendarUnit
                                            forDate:self];
    NSInteger endDay = [calendar ordinalityOfUnit:NSDayCalendarUnit
                                           inUnit:NSEraCalendarUnit
                                          forDate:date];

    return endDay - startDay;
}

- (BOOL)isOnSameDayAsDate:(NSDate *)date
{
    return [self daysUntilDate:date] == 0;
}

- (NSString *)descriptionWithFormat:(NSString *)format
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setLocale:[NSLocale currentLocale]];
    [formatter setDateFormat:format];
    NSString *s = [formatter stringFromDate:self];
    [formatter release], formatter = nil;

    return s;
}

- (NSString *)descriptionForDay
{
    NSString *dayDescription = nil;
    if ([self isToday]) {
        dayDescription = NSLocalizedString(@"global.today", nil);
    } else if ([self isTomorrow]) {
        dayDescription = NSLocalizedString(@"global.tomorrow", nil);
    } else if (![self isMoreThanWeekInTheFuture]) {
        dayDescription = [self descriptionWithFormat:@"EEE"];
    } else {
        static NSDateFormatter *formatter = nil;
        if (!formatter) {
            formatter = [[NSDateFormatter alloc] init];
            [formatter setDateStyle:NSDateFormatterShortStyle];
            [formatter setTimeStyle:NSDateFormatterNoStyle];
            [formatter setLocale:[NSLocale currentLocale]];
        }
        dayDescription = [formatter stringFromDate:self];
    }

    return dayDescription;
}

- (NSString *)prettyPrint
{
    return [NSString stringWithFormat:@"%@ %@", [self descriptionForDay],
            [self descriptionWithFormat:@"h:mm a"]];
}

+ (NSString *)textRangeWithStartDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate
{
    NSString *description = nil;
    if ([startDate isOnSameDayAsDate:endDate]) {
        NSString *dayDescription = [startDate descriptionForDay];
        NSString *timeFormat = @"h:mm a";
        NSString *startTimeDescription =
            [startDate descriptionWithFormat:timeFormat];
        NSString *endTimeDescription =
            [endDate descriptionWithFormat:timeFormat];

        description = [NSString stringWithFormat:@"%@ %@ - %@", dayDescription,
                       startTimeDescription, endTimeDescription];
    } else {
        NSString *start = [startDate prettyPrint];
        NSString *end = [endDate prettyPrint];
        description = [NSString stringWithFormat:@"%@ - %@", start, end];
    }

    return description;
}

@end
