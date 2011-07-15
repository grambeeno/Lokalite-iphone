//
//  BusinessDetailsHeaderView.m
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "BusinessDetailsHeaderView.h"

@implementation BusinessDetailsHeaderView

@synthesize imageView = imageView_;
@synthesize titleLabel = titleLabel_;

#pragma mark - Memory management

- (void)dealloc
{
    [imageView_ release];
    [titleLabel_ release];
    [super dealloc];
}

@end


#import "Business.h"

@implementation BusinessDetailsHeaderView (UserInterfaceHelpers)

- (void)configureForBusiness:(Business *)business
{
    UIImage *image = [UIImage imageWithData:[business imageData]];
    [[self imageView] setImage:image];

    [[self titleLabel] setText:[business name]];
}

@end

