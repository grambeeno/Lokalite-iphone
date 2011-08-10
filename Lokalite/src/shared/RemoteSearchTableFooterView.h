//
//  RemoteSearchTableFooterView.h
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RemoteSearchTableFooterView : UIView

@property (nonatomic, retain, readonly) UIButton *searchButton;

#pragma mark - Perform search controls

- (void)displayPerformSearchControls;

#pragma mark - Activity

- (void)displayActivity;

#pragma mark - No results

- (void)displayNoResults;

@end
