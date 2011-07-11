//
//  UIApplication+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "UIApplication+GeneralHelpers.h"

@implementation UIApplication (GeneralHelpers)

+ (NSString *)applicationDocumentsDirectory
{
    NSArray * dirs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES);
    return [dirs lastObject];
}

@end
