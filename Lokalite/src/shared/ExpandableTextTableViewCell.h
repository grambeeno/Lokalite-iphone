//
//  ExpandableTextTableViewCell.h
//  Lokalite
//
//  Created by John Debay on 8/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExpandableTextTableViewCell : UITableViewCell

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;

+ (CGFloat)cellHeightForText:(NSString *)text
                    withFont:(UIFont *)font
                    expanded:(BOOL)expanded;

@end
