//
//  LokaliteAccount+KeychainAdditions.m
//  Lokalite
//
//  Created by John Debay on 7/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteAccount+KeychainAdditions.h"
#import "SFHFKeychainUtils.h"

@implementation LokaliteAccount (KeychainAdditions)

+ (NSString *)keychainServiceName
{
    return @"com.lokalite.lokalite";
}

- (NSString *)password
{
    NSString * service = [[self class] keychainServiceName];
    NSString * email = [self email];
    
    NSError * error = nil;
    NSString * password = [SFHFKeychainUtils getPasswordForUsername:email
                                                     andServiceName:service
                                                              error:&error];

    if (error) {
        NSLog(@"Error retrieving password from keychain for user '%@': '%@'.",
              [self email], error);
        return nil;
    }

    return password;
}

- (void)setPassword:(NSString *)password
{
    NSString * service = [[self class] keychainServiceName];

    NSError * error;
        [SFHFKeychainUtils storeUsername:[self email]
                             andPassword:password
                          forServiceName:service
                          updateExisting:YES
                                   error:&error];

    if (error)
        NSLog(@"Error saving password for user '%@' in keychain: '%@'",
              [self email], error);
}

+ (void)deletePasswordForEmail:(NSString *)email
{
    NSString * service = [[self class] keychainServiceName];

    NSError * error;
        [SFHFKeychainUtils deleteItemForUsername:email
                                  andServiceName:service
                                           error:&error];

    if (error)
        NSLog(@"Error deleting keychain item for '%@'.: '%@'.", email, error);
}

@end
