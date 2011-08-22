//
//  EventDetailsHeaderView.m
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventDetailsHeaderView.h"

@implementation EventDetailsHeaderView

@synthesize imageView = imageView_;
@synthesize titleLabel = titleLabel_;
@synthesize businessNameLabel = businessNameLabel_;
@synthesize dateRangeLabel = dateRangeLabel_;
@synthesize startDateLabel = startDateLabel_;
@synthesize endDateLabel = endDateLabel_;
@synthesize trendButton = trendButton_;

#pragma mark - Memory management

- (void)dealloc
{
    [imageView_ release];
    [titleLabel_ release];
    [businessNameLabel_ release];
    [dateRangeLabel_ release];
    [startDateLabel_ release];
    [endDateLabel_ release];
    [trendButton_ release];

    [super dealloc];
}

@end



#import "Event.h"
#import "Event+GeneralHelpers.h"
#import "Business.h"
#import "NSString+GeneralHelpers.h"
#import "NSDate+GeneralHelpers.h"
#import <QuartzCore/QuartzCore.h>

@implementation EventDetailsHeaderView (UserInterfaceHelpers)

- (void)configureForEvent:(Event *)event
{
    [[self imageView] setImage:[event standardImage]];

    [[self titleLabel] setText:[event name]];
    [[self businessNameLabel] setText:
     [NSString stringWithFormat:@"@ %@", [[event business] name]]];

    [[self startDateLabel] setText:[[event startDate] timeString]];
    [[self endDateLabel] setText:[[event endDate] timeString]];

    NSString *timeRange =
        [NSString textRangeWithStartDate:[event startDate]
                                 endDate:[event endDate]];
    [[self dateRangeLabel] setText:timeRange];

    BOOL isTrending = [[event trended] boolValue];
    NSString *title =
        isTrending ?
        NSLocalizedString(@"event.untrend-event", nil) :
        NSLocalizedString(@"event.trend-event", nil);
    [[self trendButton] setTitle:title forState:UIControlStateNormal];
}

@end
