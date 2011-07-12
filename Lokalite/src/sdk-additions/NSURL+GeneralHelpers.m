//
//  NSURL+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NSURL+GeneralHelpers.h"

@implementation NSURL (GeneralHelpers)

- (NSURL *)URLByAppendingGetParameters:(NSDictionary *)params
{
    NSMutableString *s = [[self absoluteString] mutableCopy];

    if ([params count]) {
        [s appendString:@"?"];
        [params enumerateKeysAndObjectsUsingBlock:
         ^(NSString *key, NSString *value, BOOL *stop) {
             NSStringEncoding encoding = NSUTF8StringEncoding;
             NSString *encodedKey =
                [key stringByAddingPercentEscapesUsingEncoding:encoding];
             NSString *encodedValue =
                [key stringByAddingPercentEscapesUsingEncoding:encoding];
             [s appendFormat:@"%@=%@&", encodedKey, encodedValue];
         }];
    }

    NSURL *url = [NSURL URLWithString:s];
    [s release], s = nil;

    return url;
}

@end
