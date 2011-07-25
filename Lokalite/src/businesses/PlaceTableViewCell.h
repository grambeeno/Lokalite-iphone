//
//  PlaceTableViewCell.h
//  Lokalite
//
//  Created by John Debay on 7/25/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlaceTableViewCell : UITableViewCell

@property (nonatomic, retain) IBOutlet UIImageView *placeImageView;
@property (nonatomic, retain) IBOutlet UILabel *nameLabel;
@property (nonatomic, retain) IBOutlet UILabel *summaryLabel;

#pragma mark - Configuration helpers

+ (CGFloat)cellHeight;

@end



@class Business;

@interface PlaceTableViewCell (UserInterfaceHelpers)

- (void)configureCellForPlace:(Business *)place;

@end
