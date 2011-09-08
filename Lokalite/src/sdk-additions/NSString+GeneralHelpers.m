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

+ (id)stringFromLocationDistance:(CLLocationDistance)distance
{
    DistanceFormatter * formatter = [DistanceFormatter formatter];
    return [formatter distanceAsString:distance];
}

- (NSString *)formattedPhoneNumberString
{
    NSCharacterSet *digits = [NSCharacterSet decimalDigitCharacterSet];
    NSArray *comps =
        [self componentsSeparatedByCharactersInSet:[digits invertedSet]];
    NSString *stripped = [comps componentsJoinedByString:@""];

    NSString *formattedString = nil;
    if ([stripped length] == 10) {
        // phone number with area code
        NSString *areaCode = [stripped substringWithRange:NSMakeRange(0, 3)];
        NSString *prefix = [stripped substringWithRange:NSMakeRange(3, 3)];
        NSString *extension = [stripped substringWithRange:NSMakeRange(5, 4)];

        formattedString =
            [NSString stringWithFormat:@"(%@) %@-%@", areaCode, prefix,
             extension];
    } else if ([stripped length] == 7) {
        // phone number only
        NSString *prefix = [stripped substringWithRange:NSMakeRange(3, 3)];
        NSString *extension = [stripped substringWithRange:NSMakeRange(5, 4)];

        formattedString =
            [NSString stringWithFormat:@"%@-%@", prefix, extension];
    } else
        formattedString = self;

    return formattedString;
}

@end



@implementation NSString (LokaliteHelpers)

- (NSArray *)arrayByTokenizingWithString:(NSString *)token
{
    return [self componentsSeparatedByString:token];
}

@end

