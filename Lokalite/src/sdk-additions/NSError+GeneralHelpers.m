//
//  NSError+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NSError+GeneralHelpers.h"
#import <CoreData/CoreData.h>

@implementation NSError (GeneralHelpers)

- (NSString *)detailedDescription
{
    NSMutableString * desc = [self.localizedDescription mutableCopy];
    NSArray * detailedErrors = [self.userInfo objectForKey:NSDetailedErrorsKey];

    if (detailedErrors.count)
        for (NSError * detailedError in detailedErrors)
            [desc appendFormat:@"\tDetailed error: %@", detailedError.userInfo];
    else if (self.userInfo)
        [desc appendFormat:@"\t%@", self.userInfo];

    NSError * underlyingError =
        [self.userInfo objectForKey:NSUnderlyingErrorKey];
    if (underlyingError)
        [desc appendFormat:@"\tUnderlying error: %@",
            [underlyingError detailedDescription]];

    return [desc autorelease];
}

@end
