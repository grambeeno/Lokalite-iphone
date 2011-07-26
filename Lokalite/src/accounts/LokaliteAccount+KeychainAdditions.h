//
//  LokaliteAccount+KeychainAdditions.h
//  Lokalite
//
//  Created by John Debay on 7/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteAccount.h"

@interface LokaliteAccount (KeychainAdditions)

- (NSString *)password;
- (void)setPassword:(NSString *)password;

+ (void)deletePasswordForEmail:(NSString *)email;

@end
