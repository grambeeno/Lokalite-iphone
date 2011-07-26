//
//  LokaliteAccount+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteAccount.h"
#import <CoreData/CoreData.h>

@interface LokaliteAccount (GeneralHelpers)

+ (id)createOrUpdateLokaliteAccountFromJsonData:(NSDictionary *)jsonData
                                      inContext:(NSManagedObjectContext *)moc;

@end
