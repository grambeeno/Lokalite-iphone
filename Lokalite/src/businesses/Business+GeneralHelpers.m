//
//  Business+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Business+GeneralHelpers.h"

#import "NSManagedObject+GeneralHelpers.h"

@implementation Business (GeneralHelpers)

+ (id)businessWithId:(NSNumber *)businessId
           inContext:(NSManagedObjectContext *)context
{
    NSPredicate *pred =
        [NSPredicate predicateWithFormat:@"identifier == %@", businessId];
    return [self findFirstWithPredicate:pred inContext:context];
}

+ (id)existingOrNewBusinessFromJsonData:(NSDictionary *)businessData
                              inContext:(NSManagedObjectContext *)context
{
    NSNumber *businessId = [businessData objectForKey:@"id"];
    Business *business = [Business businessWithId:businessId
                                        inContext:context];
    if (!business) {
        business = [Business createInstanceInContext:context];
        [business setIdentifier:businessId];
    }

    [business setName:[businessData objectForKey:@"name"]];
    [business setPhone:[businessData objectForKey:@"phone"]];
    [business setAddress:[businessData objectForKey:@"address"]];
    [business setSummary:[businessData objectForKey:@"description"]];

    return business;
}

@end
