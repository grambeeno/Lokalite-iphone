//
//  TrendButton.m
//  Lokalite
//
//  Created by John Debay on 8/16/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TrendButton.h"
#import "UIColor+GeneralHelpers.h"

#import <QuartzCore/QuartzCore.h>

@implementation TrendButton

- (void)initialize
{
    //UIColor *buttonTextColor = [UIColor colorWithRGBValue:0x262935];
    //UIColor *buttonTextColor = [UIColor whiteColor];
    //UIColor *buttonShadowColor = //[[UIColor whiteColor] colorWithAlphaComponent:1];
    //    [UIColor darkGrayColor];
    //CGSize buttonShadowOffset = CGSizeMake(0, -1);

    UIImage *bgImage = [UIImage imageNamed:@"trend-button-background"];
    UIImage *bgImagePressed =
        [UIImage imageNamed:@"trend-button-background-pressed"];

    //const CGFloat leftCapWidth = 9, topCapHeight = 8;
    const CGFloat leftCapWidth = 10, topCapHeight = 12;
    bgImage = [bgImage stretchableImageWithLeftCapWidth:leftCapWidth
                                           topCapHeight:topCapHeight];
    bgImagePressed =
        [bgImagePressed stretchableImageWithLeftCapWidth:leftCapWidth
                                            topCapHeight:topCapHeight];
    [self setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    [[self titleLabel] setFont:[UIFont boldSystemFontOfSize:19]];
    //[[self titleLabel] setShadowOffset:buttonShadowOffset];

    [self setBackgroundImage:bgImage forState:UIControlStateNormal];
    //[self setTitleColor:buttonTextColor forState:UIControlStateNormal];
    //[self setTitleShadowColor:buttonShadowColor forState:UIControlStateNormal];

    [self setBackgroundImage:bgImagePressed
                      forState:UIControlStateHighlighted];
    [self setTitleColor:[UIColor whiteColor]
                 forState:UIControlStateHighlighted];
    [self setTitleShadowColor:[UIColor clearColor]
                       forState:UIControlStateHighlighted];

    CALayer *layer = [self layer];
    [layer setShadowColor:[[UIColor blackColor] CGColor]];
    [layer setShadowOpacity:1];
    [layer setShadowOffset:CGSizeMake(0, 1)];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
        [self initialize];

    return self;
}

- (void)awakeFromNib
{
    [super awakeFromNib];

    [self initialize];
}

@end
