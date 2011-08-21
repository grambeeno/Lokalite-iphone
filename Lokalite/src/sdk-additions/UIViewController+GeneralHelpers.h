//
//  UIViewController+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/25/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (GeneralHelpers)

#pragma mark - Displaying the activity view

- (void)displayActivityView;
- (void)displayActivityViewWithCompletion:(void (^)(void))completion;
- (void)hideActivityView;
- (void)hideActivityViewWithCompletion:(void (^)(void))completion;

@end


@interface UIViewController (LokaliteHelpers)

- (void)presentSharingOptionsWithDelegate:(id<UIActionSheetDelegate>)delegate;

@end
