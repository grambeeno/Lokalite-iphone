#import "ActivityView.h"
#import <QuartzCore/QuartzCore.h>

enum {
    InfoViewTag = 202
};


@interface ActivityView ()
- (UIView *)infoView;
@end

@implementation ActivityView

#pragma mark -
#pragma mark Initialization

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor clearColor]];

        CGFloat width = 100, height = 100;
        CGRect infoViewFrame =
            CGRectMake(round((frame.size.width - width) / 2),
                       round((frame.size.height - height) / 2),
                       width, height);
        UIView * infoView = [[UIView alloc] initWithFrame:infoViewFrame];
        [infoView setTag:InfoViewTag];
        UIColor * infoViewBackgroundColor =
            [[UIColor blackColor] colorWithAlphaComponent:0.6];
        [infoView setBackgroundColor:infoViewBackgroundColor];
        [infoView setAlpha:0];
        [[infoView layer] setCornerRadius:10];

        UIActivityIndicatorView * activityView =
            [[UIActivityIndicatorView alloc]
             initWithActivityIndicatorStyle:
             UIActivityIndicatorViewStyleWhiteLarge];
        CGRect activityViewFrame = [activityView frame];
        activityViewFrame =
            CGRectMake(round((infoViewFrame.size.width -
                              activityViewFrame.size.width) / 2),
                       round((infoViewFrame.size.height -
                              activityViewFrame.size.height) / 2),
                       activityViewFrame.size.width,
                       activityViewFrame.size.height);
        [activityView setFrame:activityViewFrame];
        [activityView startAnimating];
        [infoView addSubview:activityView];
        [activityView release], activityView = nil;

        [self addSubview:infoView];
        [infoView release], infoView = nil;
    }

    return self;
}

#pragma mark -
#pragma mark Assisting with animating the view

- (void)showActivityIndicatorWithAnimationDuration:(NSTimeInterval)duration
{
    UIView * infoView = [self infoView];

    CGRect destFrame = [infoView frame];
    CGRect srcFrame = [self frame];
    [infoView setFrame:srcFrame];

    [UIView animateWithDuration:duration
                     animations:^{
                         [infoView setFrame:destFrame];
                         [infoView setAlpha:1];
                     }];
}

- (void)hideActivityIndicatorWithAnimationDuration:(NSTimeInterval)duration
{
    UIView * infoView = [self infoView];
    [UIView animateWithDuration:duration
                     animations:^{
                         [infoView setFrame:[self frame]];
                         [infoView setAlpha:0];
                     }];
}

#pragma mark -
#pragma mark Accessors

- (UIView *)infoView
{
    return [self viewWithTag:InfoViewTag];
}

@end
