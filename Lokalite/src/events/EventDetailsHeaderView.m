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
@synthesize descriptionLabel = descriptionLabel_;

#pragma mark - Memory management

- (void)dealloc
{
    [imageView_ release];
    [titleLabel_ release];
    [businessNameLabel_ release];
    [dateRangeLabel_ release];
    [descriptionLabel_ release];

    [super dealloc];
}

@end



#import "Event.h"
#import "Business.h"
#import "NSString+GeneralHelpers.h"

@implementation EventDetailsHeaderView (UserInterfaceHelpers)

- (void)configureForEvent:(Event *)event
{
    UIImage *image = [UIImage imageWithData:[event imageData]];
    [[self imageView] setImage:image];

    [[self titleLabel] setText:[event name]];
    [[self businessNameLabel] setText:[[event business] name]];
    [[self descriptionLabel] setText:[event summary]];

    NSString *timeRange =
        [NSString textRangeWithStartDate:[event startDate]
                                 endDate:[event endDate]];
    [[self dateRangeLabel] setText:timeRange];
}

@end
