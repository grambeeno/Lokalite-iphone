//
//  Facebook+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 8/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Facebook.h"

extern NSString *LokaliteFacebookAppId;

@interface Facebook (GeneralHelpers)

- (void)saveSession;
- (void)restoreSession;

+ (NSArray *)defaultPermissions;

@end
