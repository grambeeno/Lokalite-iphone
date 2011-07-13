//
//  EventTableViewCell.h
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *eventImageView;
@property (nonatomic, retain) IBOutlet UILabel *eventNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *businessNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *summaryLabel;

#pragma mark - Configuration helpers

+ (CGFloat)cellHeight;

@end



@class Event;

@interface EventTableViewCell (UserInterfaceHelpers)

- (void)configureCellForEvent:(Event *)event;

@end
