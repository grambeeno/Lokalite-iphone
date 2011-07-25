//
//  PlaceTableViewCell.m
//  Lokalite
//
//  Created by John Debay on 7/25/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlaceTableViewCell.h"

@implementation PlaceTableViewCell

@synthesize placeId = placeId_;

@synthesize placeImageView = placeImageView_;
@synthesize nameLabel = nameLabel_;
@synthesize summaryLabel = summaryLabel_;

#pragma mark - Memory management

- (void)dealloc
{
    [placeId_ release];

    [placeImageView_ release];
    [nameLabel_ release];
    [summaryLabel_ release];

    [super dealloc];
}

#pragma mark - Configuration helpers

+ (CGFloat)cellHeight
{
    return 80;
}

@end



#import "Business.h"

@implementation PlaceTableViewCell (UserInterfaceHelpers)

- (void)configureCellForPlace:(Business *)place
{
    [self setPlaceId:[place identifier]];

    [[self nameLabel] setText:[place name]];
    [[self summaryLabel] setText:[place status]];
}

@end
