#import <UIKit/UIKit.h>

@interface ActivityView : UIView
{
}

#pragma mark Assisting with animating the view

- (void)showActivityIndicatorWithAnimationDuration:(NSTimeInterval)duration;
- (void)hideActivityIndicatorWithAnimationDuration:(NSTimeInterval)duration;

@end
