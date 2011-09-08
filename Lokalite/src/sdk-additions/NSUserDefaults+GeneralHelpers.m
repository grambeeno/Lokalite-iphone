//
//  NSUserDefaults+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 9/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NSUserDefaults+GeneralHelpers.h"

@implementation NSUserDefaults (GeneralHelpers)

+ (NSString *)promptForLocalNotificationWhenTrendingKey
{
    return @"prompt-for-local-notification-when-trending";
}

- (void)setPromptForLocalNotificationWhenTrending:(BOOL)prompting
{
    NSString *key = [[self class] promptForLocalNotificationWhenTrendingKey];
    [self setBool:prompting forKey:key];
}

- (BOOL)promptForLocalNotificationWhenTrending
{
    NSString *key = [[self class] promptForLocalNotificationWhenTrendingKey];
    NSNumber *value = [self valueForKey:key];
    if (value)
        return [self boolForKey:key];
    else
        return YES;
}

@end

