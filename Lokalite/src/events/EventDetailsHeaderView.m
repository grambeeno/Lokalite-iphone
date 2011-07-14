//
//  EventDetailsHeaderView.m
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "EventDetailsHeaderView.h"

@implementation EventDetailsHeaderView

@synthesize imageView = imageView_;
@synthesize titleLabel = titleLabel_;

#pragma mark - Memory management

- (void)dealloc
{
    [imageView_ release];
    [titleLabel_ release];

    [super dealloc];
}

@end
