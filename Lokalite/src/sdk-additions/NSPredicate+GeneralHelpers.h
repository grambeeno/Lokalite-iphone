//
//  NSPredicate+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/19/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPredicate (GeneralHelpers)

//
// Given a non-empty search string, returns an NSPredicate instance that will
// perform standard (case-insensitive, non-diacritic) text search for the
//  provided string against a set of key paths.
//
+ (NSPredicate *)standardSearchPredicateForSearchString:(NSString *)searchString
                                      attributeKeyPaths:(NSArray *)keyPaths;

@end
