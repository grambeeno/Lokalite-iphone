//
//  PlaceTableViewCell.h
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceTableViewCell : UITableViewCell

@property (nonatomic, copy) NSNumber *placeId;
@property (nonatomic, copy) NSString *placeImageUrl;

@property (nonatomic, retain) IBOutlet UIImageView *backgroundImageView;
@property (nonatomic, retain) IBOutlet UIImageView *placeImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *summaryLabel;
@property (nonatomic, retain) IBOutlet UILabel *distanceLabel;

#pragma mark - Configuration helpers

+ (CGFloat)cellHeight;

@end



@class CLLocation, Business;

@interface PlaceTableViewCell (UserInterfaceHelpers)

- (void)configureCellForPlace:(Business *)place
              displayDistance:(BOOL)displayDistance;

@end
