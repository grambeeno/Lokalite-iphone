//
//  RemoteSearchTableFooterView.m
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "RemoteSearchTableFooterView.h"

#import "SDKAdditions.h"

@interface RemoteSearchTableFooterView ()

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) UILabel *activityLabel;
@property (nonatomic, retain) UIView *horizontalLine;

@end


@implementation RemoteSearchTableFooterView

@synthesize searchButton = searchButton_;

@synthesize activityIndicator = activityIndicator_;
@synthesize activityLabel = activityLabel_;

@synthesize horizontalLine = horizontalLine_;

#pragma mark - Memory management

- (void)dealloc
{
    [searchButton_ release];

    [activityIndicator_ release];
    [activityLabel_ release];

    [horizontalLine_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setOpaque:YES];
        [self addSubview:[self searchButton]];
        [self addSubview:[self horizontalLine]];
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

        [searchButton_ setTitleColor:[UIColor colorWithRGBValue:0x1058d2]
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
        NSString *text = NSLocalizedString(@"global.searching-server", nil);
        UIFont *font = [UIFont boldSystemFontOfSize:18];
        CGSize size = [text sizeWithFont:font];
        CGFloat y = round(([self frame].size.height - size.height) / 2);
        CGFloat x = 36;

        CGRect labelFrame = CGRectMake(x, y, size.width, size.height);
        activityLabel_ =
            [[UILabel alloc] initWithFrame:labelFrame];
        [activityLabel_ setText:text];
        [activityLabel_ setFont:font];
        [activityLabel_ setTextColor:[UIColor colorWithRGBValue:0x6c6c6c]];
    }

    return activityLabel_;
}

- (UIView *)horizontalLine
{
    if (!horizontalLine_) {
        CGRect frame = [self frame];
        CGRect lineFrame =
            CGRectMake(0, frame.size.height - 1, frame.size.width, 1);
        horizontalLine_ = [[UIView alloc] initWithFrame:lineFrame];
        [horizontalLine_
         setBackgroundColor:[UIColor colorWithRGBValue:0xd8d8d8]];
    }

    return horizontalLine_;
}

@end
