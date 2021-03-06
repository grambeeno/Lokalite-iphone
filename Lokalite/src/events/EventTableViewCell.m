//
//  EventTableViewCell.m
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventTableViewCell.h"

#import "UILabel+GeneralHelpers.h"
#import "UIColor+GeneralHelpers.h"

@interface EventTableViewCell ()
- (void)configureForSelectedState:(BOOL)selected;
@end


@implementation EventTableViewCell

@synthesize eventId = eventId_;
@synthesize eventImageUrl = eventImageUrl_;

@synthesize backgroundImageView = backgroundImageView_;
@synthesize eventImageView = eventImageView_;
@synthesize eventNameLabel = eventNameLabel_;
@synthesize businessNameLabel = businessNameLabel_;
@synthesize timeLabel = timeLabel_;
@synthesize distanceLabel = distanceLabel_;
@synthesize trendedImageView = trendedImageView_;

#pragma mark - Memory management

- (void)dealloc
{
    [eventId_ release];
    [eventImageUrl_ release];

    [backgroundImageView_ release];
    [eventImageView_ release];
    [eventNameLabel_ release];
    [businessNameLabel_ release];
    [timeLabel_ release];
    [distanceLabel_ release];
    [trendedImageView_ release];

    [super dealloc];
}

#pragma mark - UITableViewCell implementation

- (void)layoutSubviews
{
    [super layoutSubviews];

    [[self distanceLabel] sizeToFit:UILabelSizeToFitAlignmentRight];

    CGRect frame = [[self contentView] frame];
    CGRect timeLabelFrame = [[self timeLabel] frame];
    CGRect distanceLabelFrame = [[self distanceLabel] frame];
    CGRect imageViewFrame = [[self eventImageView] frame];

    timeLabelFrame.size.width =
        frame.size.width - distanceLabelFrame.size.width -
        (imageViewFrame.origin.x + imageViewFrame.size.width) - 12;
    [[self timeLabel] setFrame:timeLabelFrame];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    [self configureForSelectedState:selected];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self configureForSelectedState:highlighted];
}

#pragma mark - Configuration helpers

- (void)configureForSelectedState:(BOOL)selected
{
    NSString *imageName = nil;
    UIColor *shadowColor = nil;
    if (selected) {
        imageName = @"event-cell-background-selected";
        shadowColor = [UIColor clearColor];
    } else {
        imageName = @"event-cell-background";
        shadowColor = [UIColor whiteColor];
    }

    [[self backgroundImageView] setImage:[UIImage imageNamed:imageName]];
    [[self eventNameLabel] setShadowColor:shadowColor];
    [[self businessNameLabel] setShadowColor:shadowColor];
}

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
              displayDistance:(BOOL)displayDistance
{
    [self configureCellForEvent:event rank:nil displayDistance:displayDistance];
}

- (void)configureCellForEvent:(Event *)event
                         rank:(NSNumber *)rank
              displayDistance:(BOOL)displayDistance
{
    [self setEventId:[event identifier]];
    [self setEventImageUrl:[event standardImageUrl]];

    NSString *name =
        rank ?
        [NSString stringWithFormat:@"%@. %@", rank, [event name]] :
        [event name];

    [[self eventNameLabel] setText:name];
    [[self businessNameLabel] setText:[[event business] name]];
    [[self timeLabel] setText:[event dateStringDescription]];

    [[self trendedImageView] setHidden:![event isTrended]];

    NSString *distanceText = nil;
    if (displayDistance) {
        NSNumber *distance = [event distance];
        if (distance)
            distanceText =
                [NSString stringFromLocationDistance:[distance doubleValue]];
    }
    [[self distanceLabel] setText:distanceText];

    [[self eventImageView] setImage:[event standardImage]];
}

@end
