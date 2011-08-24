//
//  ComposeTweetViewController.h
//  Lokalite
//
//  Created by John Debay on 8/24/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "ShareableObject.h"

typedef void(^CTVCShouldSend)(NSString *tweetText);
typedef void(^CTVCDidCancel)(void);

@class TwitterAccount;

@interface ComposeTweetViewController : UIViewController

@property (nonatomic, retain, readonly) TwitterAccount *twitterAccount;
@property (nonatomic, retain, readonly) id<ShareableObject> shareableObject;

@property (nonatomic, retain) IBOutlet UITextView *textView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *characterCountButton;

@property (nonatomic, copy) CTVCShouldSend shouldSendHandler;
@property (nonatomic, copy) CTVCDidCancel didCancelHandler;

#pragma mark - Initialization

- (id)initWithTwitterAccount:(TwitterAccount *)twitterAccount
             shareableObject:(id<ShareableObject>)shareableObject;

@end
