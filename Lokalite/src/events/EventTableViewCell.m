//
//  EventTableViewCell.m
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventTableViewCell.h"

@implementation EventTableViewCell

@synthesize eventId = eventId_;

@synthesize eventImageView = eventImageView_;
@synthesize eventNameLabel = eventNameLabel_;
@synthesize businessNameLabel = businessNameLabel_;
@synthesize summaryLabel = summaryLabel_;
@synthesize timeLabel = timeLabel_;
@synthesize distanceLabel = distanceLabel_;
@synthesize trendedImageView = trendedImageView_;

#pragma mark - Memory management

- (void)dealloc
{
    [eventId_ release];

    [eventImageView_ release];
    [eventNameLabel_ release];
    [businessNameLabel_ release];
    [summaryLabel_ release];
    [timeLabel_ release];
    [distanceLabel_ release];
    [trendedImageView_ release];

    [super dealloc];
}

#pragma mark - Configuration helpers

+ (CGFloat)cellHeight
{
    return 80;
}

@end


#import "Event.h"
#import "Event+GeneralHelpers.h"
#import "Business.h"
#import "NSString+GeneralHelpers.h"
#import <CoreLocation/CoreLocation.h>

@implementation EventTableViewCell (UserInterfaceHelpers)

- (void)configureCellForEvent:(Event *)event
              currentLocation:(CLLocation *)location
{
    [self setEventId:[event identifier]];

    [[self eventNameLabel] setText:[event name]];
    [[self businessNameLabel] setText:[[event business] name]];
    [[self summaryLabel] setText:[event summary]];

    NSString *timeRange =
        [NSString textRangeWithStartDate:[event startDate]
                                 endDate:[event endDate]];
    [[self timeLabel] setText:timeRange];

    [[self trendedImageView] setHidden:![event isTrended]];

    /*
    [[self distanceLabel] setHidden:!location];
    NSString *distance = nil;
    if (location) {
        CLLocationDistance dist =
            [[event locationInstance] distanceFromLocation:location];
        distance = [NSString stringFromLocationDistance:dist];
    }
     */

    NSString *distanceText = nil;
    NSNumber *distance = [event distance];
    if (distance)
        distanceText =
            [NSString stringFromLocationDistance:[distance doubleValue]];
    [[self distanceLabel] setText:distanceText];
}

@end
