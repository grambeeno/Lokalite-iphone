//
//  UIButton+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/20/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "UIButton+GeneralHelpers.h"

@implementation UIButton (GeneralHelpers)

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
