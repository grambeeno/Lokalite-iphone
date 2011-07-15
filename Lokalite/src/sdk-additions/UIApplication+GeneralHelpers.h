//
//  UIApplication+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIApplication (GeneralHelpers)

+ (NSString *)applicationDocumentsDirectory;

#pragma mark - Working with the global network activity indicator

- (void)networkActivityIsStarting;
- (void)networkActivityDidFinish;
- (NSInteger)networkActivityCount;

@end


@interface UIApplication (LokaliteHelpers)

- (NSURL *)baseLokaliteUrl;

@end
