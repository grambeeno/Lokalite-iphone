//
//  TwitterAccount+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 8/24/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TwitterAccount+GeneralHelpers.h"

#import "OAToken.h"
#import "NSManagedObject+GeneralHelpers.h"
#import "SFHFKeychainUtils.h"

@implementation TwitterAccount (GeneralHelpers)

#pragma mark - Account lifecycle

- (void)prepareForDeletion
{
    [self deleteKeyAndSecret];

    [super prepareForDeletion];
}

#pragma mark - Creation and deletion

+ (id)accountInContext:(NSManagedObjectContext *)context
{
    return [self findFirstInContext:context];
}

+ (BOOL)deleteAccountInContext:(NSManagedObjectContext *)context
{
    TwitterAccount *account = [self accountInContext:context];
    if (account) {
        [context deleteObject:account];
        return YES;
    }
    return NO;
}

+ (id)setAccountWithUserId:(NSNumber *)userId
                  username:(NSString *)username
                     token:(NSString *)token
                    secret:(NSString *)secret
                   context:(NSManagedObjectContext *)context
{
    TwitterAccount *account = [self accountInContext:context];
    if (!account)
        account = [TwitterAccount createInstanceInContext:context];

    [account setUserId:userId];
    [account setUsername:username];
    [account setToken:token andSecret:secret];

    return account;
}

//
// Keychain helpers
//

+ (NSString *)keychainServiceName
{
    return @"com.lokalite.lokalite";
}

- (NSString *)password
{
    NSString * service = [[self class] keychainServiceName];
    NSString * username = [[self userId] description];
    
    NSError * error;
    NSString * password = [SFHFKeychainUtils getPasswordForUsername:username
                                                     andServiceName:service
                                                              error:&error];

    if (error) {
        NSLog(@"Error retrieving password from keychain for user '%@': '%@'.",
              self.username, error);
        return nil;
    }

    return password;
}

- (void)setPassword:(NSString *)password
{
    NSString * service = [[self class] keychainServiceName];

    NSError * error;
    [SFHFKeychainUtils storeUsername:[[self userId] description]
                         andPassword:password
                      forServiceName:service
                      updateExisting:YES
                               error:&error];

    if (error)
        NSLog(@"Error saving password for user '%@' in keychain: '%@'",
              self.username, error);
}

- (void)setToken:(NSString *)token andSecret:(NSString *)secret
{
    [self setPassword:[NSString stringWithFormat:@"%@ %@", token, secret]];
}

- (void)deleteKeyAndSecret
{
    [[self class] deleteKeyAndSecretForUserId:[self userId]];
}

- (NSString *)token
{
    NSString * password = [self password];
    NSRange where = [password rangeOfString:@" "];
    if (where.location == NSNotFound && where.length == 0)
        return nil;

    return [password substringWithRange:NSMakeRange(0, where.location)];
}

- (NSString *)secret
{
    NSString * password = [self password];
    NSRange where = [password rangeOfString:@" "];
    if (where.location == NSNotFound && where.length == 0)
        return nil;

    NSRange secretRange =
        NSMakeRange(where.location + 1, password.length - (where.location + 1));
    return [password substringWithRange:secretRange];
}

- (OAToken *)oauthToken
{
    NSString *token = [self token];
    NSString *secret = [self secret];

    return [[[OAToken alloc] initWithKey:token secret:secret] autorelease];
}

+ (void)deleteKeyAndSecretForUserId:(NSNumber *)userId
{
    NSString * service = [[self class] keychainServiceName];

    NSError * error;
    [SFHFKeychainUtils deleteItemForUsername:[userId description]
                              andServiceName:service
                                       error:&error];

    if (error)
        NSLog(@"Error deleting keychain item for '%@'.: '%@'.", userId, error);
}

@end
