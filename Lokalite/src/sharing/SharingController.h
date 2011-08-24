//
//  SharingController.h
//  Lokalite
//
//  Created by John Debay on 8/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareableObject.h"

#import "TwitterOAuthLogInViewController.h"

#import "Facebook.h"
#import "TwitterService.h"

#import <MessageUI/MessageUI.h>

@interface SharingController : NSObject
    <UIActionSheetDelegate, UINavigationControllerDelegate,
     MFMailComposeViewControllerDelegate,
     MFMessageComposeViewControllerDelegate, FBSessionDelegate,
     FBDialogDelegate, TwitterServiceDelegate>

@property (nonatomic, retain, readonly) id<ShareableObject> shareableObject;
@property (nonatomic, retain, readonly) NSManagedObjectContext *context;

#pragma mark - Initialization

- (id)initWithShareableObject:(id<ShareableObject>)object
                      context:(NSManagedObjectContext *)context;

#pragma mark - Sharing

- (void)share;

@end
