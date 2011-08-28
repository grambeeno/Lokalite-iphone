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

- (BOOL)isOnSameDayAsDate:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];

    NSUInteger unitFlags = NSEraCalendarUnit |
                           NSYearCalendarUnit |
                           NSMonthCalendarUnit |
                           NSDayCalendarUnit;

    NSDateComponents *comps1 = [calendar components:unitFlags fromDate:self];
    NSDateComponents *comps2 = [calendar components:unitFlags fromDate:date];

    return
        [comps1 era] == [comps2 era] &&
        [comps1 year] == [comps2 year] &&
        [comps1 month] == [comps2 month] &&
        [comps1 day] == [comps2 day];
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
