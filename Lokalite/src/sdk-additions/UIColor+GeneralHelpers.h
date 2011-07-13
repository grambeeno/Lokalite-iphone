//
//  UIColor+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//


@interface UIColor (GeneralHelpers)

+ (UIColor *)colorWithRGBValue:(NSInteger)rgbValue;
+ (UIColor *)colorWithRGBValue:(NSInteger)rgbValue alpha:(CGFloat)alpha;

@end


@interface UIColor (ApplicationColors)

+ (id)navigationBarTintColor;

@end
