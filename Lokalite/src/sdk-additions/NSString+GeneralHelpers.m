//
//  NSString+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NSString+GeneralHelpers.h"
#import "DistanceFormatter.h"

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

+ (id)stringFromLocationDistance:(CLLocationDistance)distance
{
    DistanceFormatter * formatter = [DistanceFormatter formatter];
    return [formatter distanceAsString:distance];
}

@end



@implementation NSString (LokaliteHelpers)

- (NSArray *)arrayByTokenizingWithString:(NSString *)token
{
    return [self componentsSeparatedByString:token];
}

@end

