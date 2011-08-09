//
//  RemoteSearchTableFooterView.m
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "RemoteSearchTableFooterView.h"

@interface RemoteSearchTableFooterView ()

@property (nonatomic, retain) UIButton *loadMoreButton;

@end


@implementation RemoteSearchTableFooterView

@synthesize loadMoreButton = loadMoreButton_;

#pragma mark - Memory management

- (void)dealloc
{
    [loadMoreButton_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor redColor]];
        [self addSubview:[self loadMoreButton]];
    }

    return self;
}

#pragma mark - Accessors

- (UIButton *)loadMoreButton
{
    if (!loadMoreButton_) {
        loadMoreButton_ =
            [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [loadMoreButton_ setTitle:NSLocalizedString(@"global.load-more", nil)
                         forState:UIControlStateNormal];
        [loadMoreButton_ setFrame:CGRectMake(0, 0, 320, 60)];
    }

    return loadMoreButton_;
}

@end
