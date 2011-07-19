//
//  NSPredicate+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/19/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NSPredicate+GeneralHelpers.h"

@implementation NSPredicate (GeneralHelpers)

+ (NSPredicate *)standardSearchPredicateForSearchString:(NSString *)searchString
                                      attributeKeyPaths:(NSArray *)keyPaths
{
    NSCharacterSet *whitespace = [NSCharacterSet whitespaceCharacterSet];
    NSArray *components =
        [searchString componentsSeparatedByCharactersInSet:whitespace];

    NSMutableString *s = [NSMutableString string];
    NSMutableArray *args = [NSMutableArray array];

    [components enumerateObjectsUsingBlock:
     ^(NSString *component, NSUInteger idx, BOOL *stop) {
         NSLog(@"Component %d: '%@'", idx, component);
         if ([component length]) {
             if (idx)
                 [s appendString:@" AND "];

             [s appendString:@"("];
             [keyPaths enumerateObjectsUsingBlock:
              ^(NSString *keyPath, NSUInteger idx, BOOL *stop) {
                  [s appendFormat:@"%@ contains[cd] %%@", keyPath];
                  if (idx == [keyPaths count] - 1)
                      [s appendString:@")"];
                  else
                      [s appendFormat:@" OR "];

                  [args addObject:searchString];
              }];
         }
     }];

    return [NSPredicate predicateWithFormat:s argumentArray:args];
}


@end
