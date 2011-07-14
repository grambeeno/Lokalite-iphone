//
//  UIColor+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "UIColor+GeneralHelpers.h"

@implementation UIColor (GeneralHelpers)

+ (UIColor *)colorWithRGBValue:(NSInteger)rgbValue
{
    return [self colorWithRGBValue:rgbValue alpha:1];
}

+ (UIColor *)colorWithRGBValue:(NSInteger)rgbValue alpha:(CGFloat)alpha
{
    CGFloat red = ((float)((rgbValue & 0xFF0000) >> 16)) / 255.0;
    CGFloat green = ((float)((rgbValue & 0xFF00) >> 8)) / 255.0;
    CGFloat blue = ((float)(rgbValue & 0xFF)) / 255.0;

    return [UIColor colorWithRed:red green:green blue:blue alpha:alpha];
}

@end


@implementation UIColor (ApplicationColors)

+ (id)navigationBarTintColor
{
    return nil;
    //return [self colorWithRGBValue:0x1a1a1a];
    //return [self colorWithRGBValue:0x494848];
    //return [self colorWithRGBValue:0x252525];
}

@end
