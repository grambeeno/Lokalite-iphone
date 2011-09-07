//
//  EventTableViewCell.h
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventTableViewCell : UITableViewCell {
    UILabel *timeLabel;
}

@property (nonatomic, copy) NSNumber *eventId;
@property (nonatomic, copy) NSString *eventImageUrl;

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UIImageView *eventImageView;
@property (nonatomic, retain) IBOutlet UILabel *eventNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *businessNameLabel;
@property (nonatomic, retain) IBOutlet UILabel *timeLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;
@property (nonatomic, retain) IBOutlet UIImageView *trendedImageView;

#pragma mark - Configuration helpers

+ (CGFloat)cellHeight;

@end



@class CLLocation, Event;

@interface EventTableViewCell (UserInterfaceHelpers)

- (void)configureCellForEvent:(Event *)event
              displayDistance:(BOOL)displayDistance;

- (void)configureCellForEvent:(Event *)event
                         rank:(NSNumber *)rank
              displayDistance:(BOOL)displayDistance;

@end
