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

+ (id)unknownError
{
    NSString *message = NSLocalizedString(@"error.unknown-error", nil);
    NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:message
                                    forKey:NSLocalizedDescriptionKey];

    return [NSError errorWithDomain:@"Lokalite" code:-1 userInfo:userInfo];
}

@end


@implementation NSError (HTTPHelpers)

+ (id)errorForHTTPStatusCode:(NSInteger)statusCode
{
    NSString *message = nil;

    switch (statusCode) {
        case 401:
            message = NSLocalizedString(@"http.401.message", nil);
            break;
        case 404:
            message = NSLocalizedString(@"http.404.message", nil);
            break;

        default:
            message = NSLocalizedString(@"http.unknown.message", nil);
            message =
                [message stringByAppendingFormat:@" HTTP error code %d",
                 statusCode];
            break;
    }

    NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:message
                                    forKey:NSLocalizedDescriptionKey];

    return [NSError errorWithDomain:@"HTTP" code:statusCode userInfo:userInfo];
}

@end
