//
//  ExpandableTextTableViewCell.m
//  Lokalite
//
//  Created by John Debay on 8/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "ExpandableTextTableViewCell.h"

@implementation ExpandableTextTableViewCell

@synthesize expanded = expanded_;

#pragma mark - Initialization

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self)
        expanded_ = NO;

    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    [[self textLabel] setNumberOfLines:[self isExpanded] ? 0 : 2];
}

+ (CGFloat)cellHeightForText:(NSString *)text expanded:(BOOL)expanded
{
    CGSize size = [text sizeWithFont:[UIFont boldSystemFontOfSize:18]
                   constrainedToSize:CGSizeMake(280, FLT_MAX)
                       lineBreakMode:UILineBreakModeWordWrap];

    return expanded ? (size.height + 20) : MIN(size.height, 62);
}

@end
