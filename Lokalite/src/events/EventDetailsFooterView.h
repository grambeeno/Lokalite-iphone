//
//  EventDetailsFooterView.h
//  Lokalite
//
//  Created by John Debay on 7/27/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailsFooterView : UIView

@property (nonatomic, retain) IBOutlet UIButton *trendButton;

@end


@class Event;

@interface EventDetailsFooterView (UserInterfaceHelpers)

- (void)configureForEvent:(Event *)event;

@end

