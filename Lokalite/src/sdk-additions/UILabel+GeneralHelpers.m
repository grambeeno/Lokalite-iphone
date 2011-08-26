//
//  UILabel+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 8/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "UILabel+GeneralHelpers.h"

@implementation UILabel (GeneralHelpers)

- (void)sizeToFit:(UILabelSizeToFitAlignment)alignment
{
    if (alignment == UILabelSizeToFitAlignmentLeft)
        [self sizeToFit];
    else {
        CGFloat xright = [self frame].origin.x + [self frame].size.width;

        [self sizeToFit];

        CGRect frame = self.frame;
        frame.origin.x = xright - frame.size.width;

        [self setFrame:frame];
    }
}

@end
