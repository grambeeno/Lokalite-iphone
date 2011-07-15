//
//  EventTableViewCell.m
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell

@synthesize eventImageView = eventImageView_;
@synthesize eventNameLabel = eventNameLabel_;
@synthesize businessNameLabel = businessNameLabel_;
@synthesize summaryLabel = summaryLabel_;
@synthesize timeLabel = timeLabel_;

#pragma mark - Memory management

- (void)dealloc
{
    [eventImageView_ release];
    [eventNameLabel_ release];
    [businessNameLabel_ release];
    [summaryLabel_ release];
    [timeLabel_ release];

    [super dealloc];
}

#pragma mark - Configuration helpers

+ (CGFloat)cellHeight
{
    return 80;
}

@end


#import "Event.h"
#import "Business.h"
#import "NSString+GeneralHelpers.h"

@implementation EventTableViewCell (UserInterfaceHelpers)

- (void)configureCellForEvent:(Event *)event
{
    [[self eventNameLabel] setText:[event name]];
    [[self businessNameLabel] setText:[[event business] name]];
    [[self summaryLabel] setText:[event summary]];

    NSString *timeRange =
        [NSString textRangeWithStartDate:[event startDate]
                                 endDate:[event endDate]];
    [[self timeLabel] setText:timeRange];
}

@end
