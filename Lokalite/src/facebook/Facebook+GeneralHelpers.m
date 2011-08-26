//
//  Facebook+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 8/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Facebook+GeneralHelpers.h"

@implementation Facebook (GeneralHelpers)

- (void)saveSession
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:[self accessToken] forKey:@"FacebookAccessToken"];
    [defaults setObject:[self expirationDate] forKey:@"FacebookExpirationDate"];

    NSLog(@"Access token: %@", [self accessToken]);
    NSLog(@"Expiration date: %@", [self expirationDate]);
}

- (void)restoreSession
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [self setAccessToken:[defaults objectForKey:@"FacebookAccessToken"]];
    [self setExpirationDate:[defaults objectForKey:@"FacebookExpirationDate"]];

    NSLog(@"Access token: '%@'", [self accessToken]);
    NSLog(@"Expiration date: '%@'", [self expirationDate]);
}

@end
