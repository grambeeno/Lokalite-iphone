//
//  EventDetailsFooterView.m
//  Lokalite
//
//  Created by John Debay on 7/27/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventDetailsFooterView.h"

@implementation EventDetailsFooterView

@synthesize trendButton = trendButton_;

#pragma mark - Memory management

- (void)dealloc
{
    [trendButton_ release];

    [super dealloc];
}

@end



#import "Event.h"

@implementation EventDetailsFooterView (UserInterfaceHelpers)

- (void)configureForEvent:(Event *)event
{
    NSString *trendButtonTitleKey =
        [[event trended] boolValue] ? @"global.untrend" : @"global.trend";
    NSString *trendButtonTitle = NSLocalizedString(trendButtonTitleKey, nil);
    [[self trendButton] setTitle:trendButtonTitle
                        forState:UIControlStateNormal];
}

@end

