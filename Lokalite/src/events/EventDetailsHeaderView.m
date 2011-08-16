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
@synthesize dateRangeLabel = dateRangeLabel_;

#pragma mark - Memory management

- (void)dealloc
{
    [imageView_ release];
    [titleLabel_ release];
    [dateRangeLabel_ release];

    [super dealloc];
}

@end



#import "Event.h"
#import "Event+GeneralHelpers.h"
#import "Business.h"
#import "NSString+GeneralHelpers.h"

@implementation EventDetailsHeaderView (UserInterfaceHelpers)

- (void)configureForEvent:(Event *)event
{
    [[self imageView] setImage:[event standardImage]];
    [[self titleLabel] setText:[event name]];

    NSString *timeRange =
        [NSString textRangeWithStartDate:[event startDate]
                                 endDate:[event endDate]];
    [[self dateRangeLabel] setText:timeRange];
}

@end
