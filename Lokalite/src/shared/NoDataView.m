//
//  NoDataView.m
//  Lokalite
//
//  Created by John Debay on 9/2/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NoDataView.h"

@implementation NoDataView

@synthesize titleLabel = titleLabel_;
@synthesize descriptionLabel = descriptionLabel_;

#pragma mark - Memory management

- (void)dealloc
{
    [titleLabel_ release];
    [descriptionLabel_ release];

    [super dealloc];
}

#pragma mark - Instantiation

+ (id)instanceFromNib
{
    NSString *nibName = NSStringFromClass(self);
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    NSArray *objects = [nib instantiateWithOwner:self options:nil];

    return [objects objectAtIndex:0];
}

@end
