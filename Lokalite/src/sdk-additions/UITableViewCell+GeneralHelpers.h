//
//  UITableViewCell+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITableViewCell (GeneralHelpers)

+ (NSString *)defaultReuseIdentifier;
+ (id)instanceFromNib;
+ (id)instanceFromNibNamed:(NSString *)nibNameOrNil
                    bundle:(NSBundle *)bundleOrNil;

@end
