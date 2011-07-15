//
//  UIApplication+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "UIApplication+GeneralHelpers.h"

@implementation UIApplication (GeneralHelpers)

+ (NSString *)applicationDocumentsDirectory
{
    NSArray * dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    return [dirs lastObject];
}

#pragma mark - Working with the global network activity indicator

static NSInteger networkActivityCount = 0;

- (void)networkActivityIsStarting
{
    if (networkActivityCount++ == 0)
        self.networkActivityIndicatorVisible = YES;
}

- (void)networkActivityDidFinish
{
    networkActivityCount = MAX(networkActivityCount - 1, 0);
    if (networkActivityCount == 0)
        self.networkActivityIndicatorVisible = NO;
}

- (NSInteger)networkActivityCount
{
    return networkActivityCount;
}

@end



@implementation UIApplication (LokaliteHelpers)

- (NSURL *)baseLokaliteUrl
{
    NSString *key = @"LokaliteAPIServer";
    NSString *s = [[NSBundle mainBundle] objectForInfoDictionaryKey:key];

    return [NSURL URLWithString:s];
}

@end

