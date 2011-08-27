//
//  Facebook+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 8/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Facebook+GeneralHelpers.h"

NSString *LokaliteFacebookAppId = @"206217952760561";

@implementation Facebook (GeneralHelpers)

- (void)saveSession
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [defaults setObject:[self accessToken] forKey:@"FacebookAccessToken"];
    [defaults setObject:[self expirationDate] forKey:@"FacebookExpirationDate"];
}

- (void)restoreSession
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];

    [self setAccessToken:[defaults objectForKey:@"FacebookAccessToken"]];
    [self setExpirationDate:[defaults objectForKey:@"FacebookExpirationDate"]];
}

+ (NSArray *)defaultPermissions
{
    return [NSArray arrayWithObject:@"publish_stream"];
}

@end
