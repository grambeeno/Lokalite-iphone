//
//  SharingController.h
//  Lokalite
//
//  Created by John Debay on 8/22/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShareableObject.h"

#import <MessageUI/MessageUI.h>

@interface SharingController : NSObject
    <UIActionSheetDelegate, MFMailComposeViewControllerDelegate,
     UINavigationControllerDelegate>

@property (nonatomic, retain, readonly) id<ShareableObject> shareableObject;

#pragma mark - Initialization

- (id)initWithShareableObject:(id<ShareableObject>)object;

#pragma mark - Sharing

- (void)share;

@end
