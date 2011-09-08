//
//  NSUserDefaults+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 9/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSUserDefaults (GeneralHelpers)

+ (NSString *)promptForLocalNotificationWhenTrendingKey;
- (void)setPromptForLocalNotificationWhenTrending:(BOOL)prompting;
- (BOOL)promptForLocalNotificationWhenTrending;

@end
