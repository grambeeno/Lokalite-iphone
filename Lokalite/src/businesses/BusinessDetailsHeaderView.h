//
//  BusinessDetailsHeaderView.h
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BusinessDetailsHeaderView : UIView

@property (nonatomic, retain) IBOutlet UIImageView *imageView;
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;

@end


@class Business;

@interface BusinessDetailsHeaderView (UserInterfaceHelpers)

- (void)configureForBusiness:(Business *)business;

@end

