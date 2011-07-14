//
//  Business+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Business+GeneralHelpers.h"

#import "NSObject+GeneralHelpers.h"
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

    NSString *name = [businessData objectForKey:@"name"];
    [business setValueIfNecessary:name forKey:@"name"];

    NSString *phone = [businessData objectForKey:@"phone"];
    [business setValueIfNecessary:phone forKey:@"phone"];

    NSString *address = [businessData objectForKey:@"address"];
    [business setValueIfNecessary:address forKey:@"address"];

    NSString *summary = [businessData objectForKey:@"description"];
    [business setValueIfNecessary:summary forKey:@"summary"];

    NSDictionary *imageData =
        [[businessData objectForKey:@"image"] objectForKey:@"image"];
    if (imageData) {
        NSString *url = [imageData objectForKey:@"url"];
        if ([business setValueIfNecessary:url forKey:@"imageUrl"])
            [business setImageData:nil];
    }

    return business;
}

@end
