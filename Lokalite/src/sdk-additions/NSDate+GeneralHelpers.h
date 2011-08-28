//
//  NSDate+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (GeneralHelpers)

+ (id)dateFromLokaliteServerString:(NSString *)string;

- (NSString *)timeString;

- (BOOL)isToday;
- (BOOL)isTomorrow;
- (BOOL)isThisWeek;
- (BOOL)isMoreThanWeekInTheFuture;

- (NSInteger)daysUntilDate:(NSDate *)date;
- (BOOL)isOnSameDayAsDate:(NSDate *)date;

+ (NSString *)textRangeWithStartDate:(NSDate *)startDate
                             endDate:(NSDate *)endDate;

@end
