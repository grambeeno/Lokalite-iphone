//
//  NSString+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NSString+GeneralHelpers.h"

@implementation NSString (GeneralHelpers)

+ (id)textRangeWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate
{
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setLocale:[NSLocale currentLocale]];
        [formatter setDateStyle:NSDateFormatterNoStyle];
        [formatter setTimeStyle:NSDateFormatterShortStyle];
    }

    return [NSString stringWithFormat:@"%@ - %@",
            [formatter stringFromDate:startDate],
            [formatter stringFromDate:endDate]];
}

@end
