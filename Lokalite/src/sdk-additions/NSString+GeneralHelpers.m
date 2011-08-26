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

@end



@implementation NSString (LokaliteHelpers)

- (NSArray *)arrayByTokenizingWithString:(NSString *)token
{
    return [self componentsSeparatedByString:token];
}

@end

