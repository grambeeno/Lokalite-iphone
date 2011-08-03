//
//  UIButton+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "UIButton+GeneralHelpers.h"

@implementation UIButton (GeneralHelpers)

+ (id)standardButton
{
    UIColor *buttonTextColor =
        [UIColor colorWithRed:.349 green:.408 blue:.58 alpha:1];

    UIImage *bgImage = [UIImage imageNamed:@"standard-button-background"];
    UIImage *bgImagePressed =
        [UIImage imageNamed:@"standard-button-background-pressed"];
    bgImage = [bgImage stretchableImageWithLeftCapWidth:9 topCapHeight:0];
    bgImagePressed = [bgImagePressed stretchableImageWithLeftCapWidth:9
                                                         topCapHeight:0];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setAutoresizingMask:UIViewAutoresizingFlexibleWidth];

    [[button titleLabel] setFont:[UIFont boldSystemFontOfSize:14]];
    [[button titleLabel] setShadowOffset:CGSizeMake(0, 1)];

    [button setBackgroundImage:bgImage forState:UIControlStateNormal];
    [button setTitleColor:buttonTextColor forState:UIControlStateNormal];
    [button setTitleShadowColor:[UIColor whiteColor]
                       forState:UIControlStateNormal];
 
    [button setBackgroundImage:bgImagePressed
                      forState:UIControlStateHighlighted];
    [button setTitleColor:[UIColor whiteColor]
                 forState:UIControlStateHighlighted];
    [button setTitleShadowColor:[UIColor clearColor]
                       forState:UIControlStateHighlighted];

    return button;
}

+ (id)lokaliteCategoryButtonWithFrame:(CGRect)frame
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setFrame:frame];

    const CGFloat leftCapWidth = 7, topCapHeight = 15;
    UIImage *backgroundImage =
        [[UIImage imageNamed:@"category-button"]
         stretchableImageWithLeftCapWidth:leftCapWidth
                             topCapHeight:topCapHeight];
    UIImage *backgroundImagePressed =
        [[UIImage imageNamed:@"category-button-pressed"]
         stretchableImageWithLeftCapWidth:leftCapWidth
                             topCapHeight:topCapHeight];

    [button setBackgroundImage:backgroundImage forState:UIControlStateNormal];
    [button setBackgroundImage:backgroundImagePressed
                      forState:UIControlStateHighlighted];

    return button;
}

@end
