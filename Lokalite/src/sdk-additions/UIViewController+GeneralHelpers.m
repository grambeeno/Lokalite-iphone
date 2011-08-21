//
//  UIViewController+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/25/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "UIViewController+GeneralHelpers.h"
#import "LokaliteAppDelegate.h"

@implementation UIViewController (GeneralHelpers)

#pragma mark - Displaying the activity view

- (void)displayActivityView
{
    [self displayActivityViewWithCompletion:nil];
}

- (void)displayActivityViewWithCompletion:(void (^)(void))completion
{
    LokaliteAppDelegate *delegate =
    (LokaliteAppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate displayActivityViewAnimated:YES completion:completion];
}

- (void)hideActivityView
{
    [self hideActivityViewWithCompletion:nil];
}

- (void)hideActivityViewWithCompletion:(void (^)(void))completion
{
    LokaliteAppDelegate *delegate =
    (LokaliteAppDelegate *) [[UIApplication sharedApplication] delegate];
    [delegate hideActivityViewAnimated:YES completion:completion];
}



@end


@implementation UIViewController (LokaliteHelpers)

- (void)presentSharingOptionsWithDelegate:(id<UIActionSheetDelegate>)delegate
{
    NSString *title = nil;
    NSString *cancelButtonTitle = NSLocalizedString(@"global.cancel", nil);
    NSString *sendEmailButtonTitle =
        NSLocalizedString(@"global.send-email", nil);
    NSString *sendTextMessageButtonTitle =
        NSLocalizedString(@"global.send-text-message", nil);
    NSString *postToFacebookButtonTitle =
        NSLocalizedString(@"global.post-to-facebook", nil);
    NSString *postToTwitterButtonTitle =
        NSLocalizedString(@"global.post-to-twitter", nil);

    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:title
                                    delegate:delegate
                           cancelButtonTitle:cancelButtonTitle
                      destructiveButtonTitle:nil
                           otherButtonTitles:sendEmailButtonTitle,
                                             sendTextMessageButtonTitle,
                                             postToFacebookButtonTitle,
                                             postToTwitterButtonTitle, nil];

    LokaliteAppDelegate *appDelegate =
        (LokaliteAppDelegate *) [[UIApplication sharedApplication] delegate];
    UITabBar *tabBar = [[appDelegate tabBarController] tabBar];
    [sheet showFromTabBar:tabBar];
    [sheet release], sheet = nil;
}    

@end
