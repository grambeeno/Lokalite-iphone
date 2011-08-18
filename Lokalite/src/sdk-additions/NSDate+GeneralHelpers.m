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
        [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'"];
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

@end
