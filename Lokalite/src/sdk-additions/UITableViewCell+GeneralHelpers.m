//
//  UITableViewCell+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "UITableViewCell+GeneralHelpers.h"

@implementation UITableViewCell (GeneralHelpers)

+ (NSString *)defaultReuseIdentifier
{
    return NSStringFromClass([self class]);
}

+ (id)instanceFromNib
{
    NSString *nibName = NSStringFromClass(self);
    return [self instanceFromNibNamed:nibName bundle:nil];
}

+ (id)instanceFromNibNamed:(NSString *)nibNameOrNil
                    bundle:(NSBundle *)bundleOrNil
{
    UINib *nib = [UINib nibWithNibName:nibNameOrNil bundle:bundleOrNil];
    NSArray *objects = [nib instantiateWithOwner:self options:nil];
    return [objects objectAtIndex:0];
}

@end
