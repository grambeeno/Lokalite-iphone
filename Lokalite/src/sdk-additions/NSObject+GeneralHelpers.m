//
//  NSObject+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NSObject+GeneralHelpers.h"

@implementation NSObject (GeneralHelpers)

- (BOOL)setValueIfNecessary:(id)value forKey:(NSString *)key
{
    id current = [self valueForKey:key];
    if (![current isEqual:value]) {
        [self setValue:value forKey:key];
        return YES;
    }

    return NO;
}

@end
