//
//  NSArray+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (GeneralHelpers)

- (NSArray *)arrayByMappingArray:(id (^)(id obj, NSUInteger idx, BOOL *stop))f;

- (NSArray *)arrayByRemovingObjectsPassingTest:
    (BOOL (^)(id obj, NSUInteger idx, BOOL *stop))predicate;

- (NSArray *)arrayByCompactingContents;

- (NSArray *)arrayByRemovingObjectsInArray:(NSArray *)array
                               passingTest:(BOOL (^)(id obj1, id obj2))pred;

@end



@interface NSArray (LokaliteHelpers)

- (NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)replacement
                                 passingTest:(BOOL (^)(id obj))predicate;

+ (NSArray *)mapAnnotationsFromLokaliteObjects:(NSArray *)objects;

@end
