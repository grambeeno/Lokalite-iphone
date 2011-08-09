//
//  RemoteSearchTableFooterView.m
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "RemoteSearchTableFooterView.h"

@interface RemoteSearchTableFooterView ()

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UILabel *activityLabel;

@end


@implementation RemoteSearchTableFooterView

@synthesize searchButton = searchButton_;

@synthesize activityIndicator = activityIndicator_;
@synthesize activityLabel = activityLabel_;

#pragma mark - Memory management

- (void)dealloc
{
    [searchButton_ release];

    [activityIndicator_ release];
    [activityLabel_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:YES];
        [self addSubview:[self searchButton]];
    }

    return self;
}

#pragma mark - Activity

- (void)displayActivity
{
    [[self searchButton] removeFromSuperview];
    [self addSubview:[self activityIndicator]];
    [self addSubview:[self activityLabel]];
}

- (void)hideActivity
{
    [[self activityIndicator] removeFromSuperview];
    [[self activityLabel] removeFromSuperview];
    [self addSubview:[self searchButton]];

    [self setActivityIndicator:nil];
    [self setActivityLabel:nil];
}

#pragma mark - Accessors

- (UIButton *)searchButton
{
    if (!searchButton_) {
        searchButton_ =
            [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        [searchButton_ setTitle:NSLocalizedString(@"global.search-server", nil)
                       forState:UIControlStateNormal];
        UIFont *font = [[searchButton_ titleLabel] font];
        font = [UIFont boldSystemFontOfSize:[font pointSize]];
        [[searchButton_ titleLabel] setFont:font];

        [searchButton_ setTitleColor:[UIColor blackColor]
                            forState:UIControlStateNormal];

        CGRect frame = [self frame];
        [searchButton_
         setFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    }

    return searchButton_;
}

- (UIActivityIndicatorView *)activityIndicator
{
    if (!activityIndicator_) {
        activityIndicator_ =    
            [[UIActivityIndicatorView alloc]
             initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];

        CGRect frame = [self frame];
        CGRect activityFrame = [activityIndicator_ frame];
        activityFrame.origin =
            CGPointMake(10,
                        round((frame.size.height - activityFrame.size.height) /
                              2));
        [activityIndicator_ setFrame:activityFrame];

        [activityIndicator_ startAnimating];
    }

    return activityIndicator_;
}

- (UILabel *)activityLabel
{
    if (!activityLabel_) {
        CGRect labelFrame = CGRectMake(36, 0, 260, [self frame].size.height);
        activityLabel_ =
            [[UILabel alloc] initWithFrame:labelFrame];
        [activityLabel_
         setText:NSLocalizedString(@"global.searching-server", nil)];
        [activityLabel_ setFont:[UIFont boldSystemFontOfSize:18]];
        [activityLabel_ setTextColor:[UIColor grayColor]];
    }

    return activityLabel_;
}

@end
