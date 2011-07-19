//
//  LokaliteObjectBuilder.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface LokaliteObjectBuilder : NSObject

+ (NSArray *)createOrUpdateEventsInJsonArray:(NSArray *)jsonObjects
                                   inContext:(NSManagedObjectContext *)context;

+ (NSArray *)replaceEventsInContext:(NSManagedObjectContext *)context
             withObjectsInJsonArray:(NSArray *)jsonObjects;

@end


@interface LokaliteObjectBuilder (GeneralHelpers)

+ (void)replaceLokaliteObjects:(NSArray *)original
                   withObjects:(NSArray *)replacement
               usingValueOfKey:(NSString *)key
              remainingHandler:(void (^)(id remainingObject))handler;

@end


@interface NSArray (LokaliteHelpers)

- (NSArray *)arrayByRemovingObjectsFromArray:(NSArray *)replacement
                                 passingTest:(BOOL (^)(id obj))predicate;

@end
