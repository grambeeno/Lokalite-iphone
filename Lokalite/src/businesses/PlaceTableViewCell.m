//
//  PlaceTableViewCell.m
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlaceTableViewCell.h"

#import "UILabel+GeneralHelpers.h"
#import "UIColor+GeneralHelpers.h"

@interface PlaceTableViewCell ()
- (void)configureForSelectedState:(BOOL)selected;
@end

@implementation PlaceTableViewCell

@synthesize placeId = placeId_;
@synthesize placeImageUrl = placeImageUrl_;

@synthesize backgroundImageView = backgroundImageView_;
@synthesize placeImageView = placeImageView_;
@synthesize nameLabel = nameLabel_;
@synthesize summaryLabel = summaryLabel_;
@synthesize distanceLabel = distanceLabel_;

#pragma mark - Memory management

- (void)dealloc
{
    [placeId_ release];
    [placeImageUrl_ release];

    [backgroundImageView_ release];
    [placeImageView_ release];
    [nameLabel_ release];
    [summaryLabel_ release];
    [distanceLabel_ release];

    [super dealloc];
}

#pragma mark - UITableViewCell implementation

- (void)layoutSubviews
{
    [super layoutSubviews];

    [[self distanceLabel] sizeToFit:UILabelSizeToFitAlignmentRight];

    CGRect frame = [[self contentView] frame];
    CGRect summaryLabelFrame = [[self summaryLabel] frame];
    CGRect distanceLabelFrame = [[self distanceLabel] frame];
    CGRect imageViewFrame = [[self placeImageView] frame];

    summaryLabelFrame.size.width =
        frame.size.width - distanceLabelFrame.size.width -
        (imageViewFrame.origin.x + imageViewFrame.size.width) - 12;
    [[self summaryLabel] setFrame:summaryLabelFrame];
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
    [[self nameLabel] setShadowColor:shadowColor];
    [[self summaryLabel] setShadowColor:shadowColor];
}


+ (CGFloat)cellHeight
{
    return 80;
}

@end


#import "Business.h"
#import "Business+GeneralHelpers.h"
#import "NSString+GeneralHelpers.h"
#import <CoreLocation/CoreLocation.h>

@implementation PlaceTableViewCell (UserInterfaceHelpers)

- (void)configureCellForPlace:(Business *)place
              displayDistance:(BOOL)displayDistance
{
    [self setPlaceId:[place identifier]];
    [self setPlaceImageUrl:[place standardImageUrl]];

    [[self nameLabel] setText:[place name]];
    [[self summaryLabel] setText:[place summary]];

    NSString *distanceText = nil;
    if (displayDistance) {
        NSNumber *distance = [place distance];
        if (distance)
            distanceText =
                [NSString stringFromLocationDistance:[distance doubleValue]];
    }
    [[self distanceLabel] setText:distanceText];

    [[self placeImageView] setImage:[place standardImage]];
}

@end
