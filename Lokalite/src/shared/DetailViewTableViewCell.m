//
//  DetailViewTableViewCell.m
//  Lokalite
//
//  Created by John Debay on 8/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "DetailViewTableViewCell.h"

@implementation DetailViewTableViewCell

- (void)awakeFromNib
{
    [super awakeFromNib];

    [[self textLabel] setTextColor:[UIColor clearColor]];
}

@end
