//
//  NSArray+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NSArray+GeneralHelpers.h"

@interface NSNull (BlockHelpers)
// Returns the opposite of -isEqual:; needed to avoid an incompatible block
// syntax error; is there a better way to get around that?
- (BOOL)isNotEqual:(id)obj;
@end

@implementation NSNull (BlockHelpers)
- (BOOL)isNotEqual:(id)obj
{
    return ![self isEqual:obj];
}
@end

@implementation NSArray (GeneralHelpers)

- (NSArray *)arrayByMappingArray:(id (^)(id, NSUInteger, BOOL *))fun
{
    NSMutableArray *mapped = [NSMutableArray arrayWithCapacity:[self count]];
    [self enumerateObjectsUsingBlock:^(id object, NSUInteger idx, BOOL *stop) {
        BOOL shouldStop = NO;
        id mappedObject = fun(object, idx, &shouldStop);
        if (shouldStop)
            *stop = YES;
        else
            [mapped addObject:mappedObject ? mappedObject : [NSNull null]];
    }];

    return mapped;
}

- (NSArray *)arrayByIncludingObjectsPassingTest:
    (BOOL (^)(id, NSUInteger, BOOL *))predicate
{
    NSIndexSet *indexes =
        [self indexesOfObjectsPassingTest:
         ^BOOL(id obj, NSUInteger idx, BOOL *stop) {
             BOOL shouldStop = NO;
             BOOL answer = predicate(obj, idx, &shouldStop);
             if (shouldStop)
                 *stop = YES;
             return answer;
    }];

    NSMutableArray *objects = [[self mutableCopy] autorelease];
    [objects removeObjectsAtIndexes:indexes];

    return objects;
}

- (NSArray *)arrayByCompactingContents
{
    return [self arrayByIncludingObjectsPassingTest:
            ^(id obj, NSUInteger idx, BOOL *stop) {
                return [[NSNull null] isNotEqual:obj];
            }];
}

@end