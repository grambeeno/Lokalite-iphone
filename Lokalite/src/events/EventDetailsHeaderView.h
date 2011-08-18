//
//  EventDetailsHeaderView.h
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventDetailsHeaderView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UILabel *businessNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *dateRangeLabel;
@property (nonatomic, retain) IBOutlet UILabel *startDateLabel;
@property (nonatomic, retain) IBOutlet UILabel *endDateLabel;


@end



@class Event;

@interface EventDetailsHeaderView (UserInterfaceHelpers)

- (void)configureForEvent:(Event *)event;

@end
