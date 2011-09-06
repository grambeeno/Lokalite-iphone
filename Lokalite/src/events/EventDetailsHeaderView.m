//
//  EventDetailsHeaderView.m
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventDetailsHeaderView.h"

#import <QuartzCore/QuartzCore.h>


// HACK: need to change if nib changes
static const CGFloat IMAGE_WRAPPER_VIEW_DEFAULT_Y = 10;


@implementation EventDetailsHeaderView

@synthesize imageWrapperView = imageWrapperView_;
@synthesize imageView = imageView_;

@synthesize infoWrapperView = infoWrapperView_;
@synthesize infoWrapperBackgroundImageView = infoWrapperBackgroundImageView_;
@synthesize trendedBadgeView = trendedBadgeView_;
@synthesize titleLabel = titleLabel_;
@synthesize businessNameLabel = businessNameLabel_;
@synthesize dateRangeLabel = dateRangeLabel_;
@synthesize startDateLabel = startDateLabel_;
@synthesize endDateLabel = endDateLabel_;
@synthesize trendView = trendView_;
@synthesize trendButton = trendButton_;

#pragma mark - Memory management

- (void)dealloc
{
    [imageWrapperView_ release];
    [imageView_ release];

    [infoWrapperView_ release];
    [infoWrapperBackgroundImageView_ release];
    [trendedBadgeView_ release];
    [titleLabel_ release];
    [businessNameLabel_ release];
    [dateRangeLabel_ release];
    [startDateLabel_ release];
    [endDateLabel_ release];
    [trendView_ release];
    [trendButton_ release];

    [super dealloc];
}

#pragma mark - UIView implementation

- (void)awakeFromNib
{
    [super awakeFromNib];

    [[[self imageView] layer] setCornerRadius:10];

    UIImage *bgImage = [[self infoWrapperBackgroundImageView] image];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:0 topCapHeight:10];
    [[self infoWrapperBackgroundImageView] setImage:bgImage];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    CGRect viewFrame = [self frame];

    CGRect titleFrame = [[self titleLabel] frame];
    CGFloat titleWidth = titleFrame.size.width;
    UIFont *titleFont = [[self titleLabel] font];
    NSString *title = [[self titleLabel] text];
    UILineBreakMode titleLineBreakMode = [[self titleLabel] lineBreakMode];

    CGSize titleSize = [title sizeWithFont:titleFont
                         constrainedToSize:CGSizeMake(titleWidth, FLT_MAX)
                             lineBreakMode:titleLineBreakMode];
    titleFrame.size.height = titleSize.height;

    CGRect businessFrame = [[self businessNameLabel] frame];
    CGFloat businessWidth = titleFrame.size.width;  // same width as the title
    UIFont *businessFont = [[self businessNameLabel] font];
    NSString *businessName = [[self businessNameLabel] text];
    UILineBreakMode businessLineBreakMode =
        [[self businessNameLabel] lineBreakMode];

    CGSize businessSize =
        [businessName sizeWithFont:businessFont
                 constrainedToSize:CGSizeMake(businessWidth, FLT_MAX)
                     lineBreakMode:businessLineBreakMode];
    businessFrame.size.height = businessSize.height;
    businessFrame.origin.y = titleFrame.origin.y + titleFrame.size.height;

    CGFloat labelHeight =
        (businessFrame.origin.y + businessFrame.size.height) -
        titleFrame.origin.y + 5;;
    CGRect imageWrapperFrame = [[self imageWrapperView] frame];
    if (labelHeight <= imageWrapperFrame.size.height) {
        // center both the title and business title labels vertically with
        // respect to the image view
        titleFrame.origin.y =
            MAX(imageWrapperFrame.origin.y,
                imageWrapperFrame.origin.y +
                round((imageWrapperFrame.size.height - labelHeight) / 2));
        businessFrame.origin.y =
            titleFrame.origin.y + titleFrame.size.height + 4;
        imageWrapperFrame.origin.y = IMAGE_WRAPPER_VIEW_DEFAULT_Y;
    } else {
        // center the title view with respect to the image view
        titleFrame.origin.y =
            MAX(imageWrapperFrame.origin.y,
                imageWrapperFrame.origin.y +
                round((imageWrapperFrame.size.height - titleFrame.size.height)
                      / 2));

        // vertically center the image view with respect to the title labe
        imageWrapperFrame.origin.y =
            IMAGE_WRAPPER_VIEW_DEFAULT_Y +
            round((titleFrame.size.height - imageWrapperFrame.size.height) / 2);

        businessFrame.origin.y =
            MAX(titleFrame.origin.y + titleFrame.size.height,
                imageWrapperFrame.origin.y +
                imageWrapperFrame.size.height);
        businessFrame.origin.x = imageWrapperFrame.origin.x;
        businessFrame.size.width =
            viewFrame.size.width - businessFrame.origin.x * 2;
        CGSize maxBusinessSize = CGSizeMake(businessFrame.size.width, FLT_MAX);

        // recalculate height of the business label
        businessFrame.size =
            [businessName sizeWithFont:businessFont
                     constrainedToSize:maxBusinessSize
                         lineBreakMode:businessLineBreakMode];

        // some vertical padding
        const CGFloat verticalPadding = 10;
        businessFrame.origin.y += verticalPadding;

        CGRect infoViewFrame = [[self infoWrapperView] frame];
        infoViewFrame.size.height =
            businessFrame.origin.y + businessFrame.size.height +
            verticalPadding;
        [[self infoWrapperView] setFrame:infoViewFrame];

        // the trend view doesn't need to be pushed down because it has correct
        // autoresize mask set. Just use its height to calculate the new height
        // of the view.
        CGRect trendFrame = [[self trendView] frame];

        // resize the entire view
        viewFrame.size.height =
            infoViewFrame.origin.y + infoViewFrame.size.height +
            trendFrame.size.height;
    }

    [self setFrame:viewFrame];
    [[self titleLabel] setFrame:titleFrame];
    [[self businessNameLabel] setFrame:businessFrame];
    [[self imageWrapperView] setFrame:imageWrapperFrame];
}

@end



#import "Event.h"
#import "Event+GeneralHelpers.h"
#import "Business.h"
#import "NSDate+GeneralHelpers.h"
#import <QuartzCore/QuartzCore.h>

@implementation EventDetailsHeaderView (UserInterfaceHelpers)

- (void)configureForEvent:(Event *)event
{
    [[self trendedBadgeView] setHidden:![event isTrended]];

    [[self imageView] setImage:[event standardImage]];

    [[self titleLabel] setText:[event name]];
    [[self businessNameLabel] setText:[[event business] name]];

    [[self startDateLabel] setText:[[event startDate] timeString]];
    [[self endDateLabel] setText:[[event endDate] timeString]];

    NSString *timeRange = [NSDate textRangeWithStartDate:[event startDate]
                                                 endDate:[event endDate]];
    [[self dateRangeLabel] setText:timeRange];

    BOOL isTrending = [[event trended] boolValue];
    NSString *title =
        isTrending ?
        NSLocalizedString(@"event.untrend-event", nil) :
        NSLocalizedString(@"event.trend-event", nil);
    [[self trendButton] setTitle:title forState:UIControlStateNormal];

    [self layoutIfNeeded];
}

@end
