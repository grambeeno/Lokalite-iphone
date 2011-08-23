//
//  ShareableObject.h
//  Lokalite
//
//  Created by John Debay on 8/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ShareableObject <NSObject>

#pragma mark - Web

- (NSURL *)lokaliteUrl;

#pragma mark - Email

- (NSString *)emailSubject;
- (NSString *)emailHTMLBody;

#pragma mark - SMS

- (NSString *)smsBody;

#pragma mark - Facebook

- (NSURL *)facebookImageUrl;
- (NSString *)facebookCaption;
- (NSString *)facebookDescription;

@end
