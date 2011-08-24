//
//  TwitterAccount+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 8/24/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TwitterAccount.h"

@class OAToken;

@interface TwitterAccount (GeneralHelpers)

//
// Each app has a single Twitter account associated with it. 
//

+ (id)accountInContext:(NSManagedObjectContext *)context;
+ (BOOL)deleteAccountInContext:(NSManagedObjectContext *)context;

+ (id)setAccountWithUserId:(NSNumber *)userId
                  username:(NSString *)username
                     token:(NSString *)token
                    secret:(NSString *)secret
                   context:(NSManagedObjectContext *)context;


//
// Keychain helpers
//

- (void)setToken:(NSString *)token andSecret:(NSString *)secret;
- (void)deleteKeyAndSecret;

- (NSString *)token;
- (NSString *)secret;

- (OAToken *)oauthToken;

+ (void)deleteKeyAndSecretForUserId:(NSNumber *)userId;

@end