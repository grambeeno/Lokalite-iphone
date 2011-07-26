//
//  LokaliteAccount+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteAccount+GeneralHelpers.h"

#import "SDKAdditions.h"

@implementation LokaliteAccount (GeneralHelpers)

+ (id)createOrUpdateLokaliteAccountFromJsonData:(NSDictionary *)jsonData
                                      inContext:(NSManagedObjectContext *)moc
{
    NSNumber *identifier = [jsonData objectForKey:@"id"];
    LokaliteAccount *account = [self instanceWithIdentifier:identifier
                                                  inContext:moc];
    if (!account) {
        account = [self createInstanceInContext:moc];
        [account setIdentifier:identifier];
    }

    NSString *email = [jsonData objectForKey:@"email"];
    [account setValueIfNecessary:email forKey:@"email"];

    NSString *creationString = [jsonData objectForKey:@"created_at"];
    NSDate *creationDate = [NSDate dateFromLokaliteServerString:creationString];
    [account setValueIfNecessary:creationDate forKey:@"creationDate"];

    return account;
}

@end
