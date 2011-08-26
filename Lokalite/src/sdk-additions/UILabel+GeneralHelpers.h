//
//  UILabel+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 8/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum UILabelSizeToFitAlignment {
    UILabelSizeToFitAlignmentLeft,
    UILabelSizeToFitAlignmentRight
} UILabelSizeToFitAlignment;

@interface UILabel (GeneralHelpers)

- (void)sizeToFit:(UILabelSizeToFitAlignment)alignment;

@end
