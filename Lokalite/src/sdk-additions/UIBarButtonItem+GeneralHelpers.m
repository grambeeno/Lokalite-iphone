//
//  UIBarButtonItem+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 8/2/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "UIBarButtonItem+GeneralHelpers.h"

@implementation UIBarButtonItem (GeneralHelpers)

+ (UIBarButtonItem *)mapViewBarButtonItemWithTarget:(id)target
                                             action:(SEL)action
{
    UIImage *mapViewImage = [UIImage imageNamed:@"radar"];
    UIBarButtonItem *toggleMapViewButton =
        [[UIBarButtonItem alloc]
         initWithImage:mapViewImage
                 style:UIBarButtonItemStyleBordered
                target:target
                action:action];
    return [toggleMapViewButton autorelease];
}

@end
