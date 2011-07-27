//
//  NSManagedObject+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <CoreData/CoreData.h>

@interface NSManagedObject (GeneralHelpers)

+ (id)createInstanceInContext:(NSManagedObjectContext *)context;

+ (NSArray *)findAllInContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllInObjectIdsContext:(NSManagedObjectContext *)context;

+ (id)findAllWithPredicate:(NSPredicate *)predicate
                 inContext:(NSManagedObjectContext *)context;
+ (id)findAllWithPredicate:(NSPredicate *)predicate
                fetchLimit:(NSInteger)fetchLimit
                 inContext:(NSManagedObjectContext *)context;
+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate
                       fetchLimit:(NSInteger)fetchLimit
                       resultType:(NSFetchRequestResultType)resultType
                        inContext:(NSManagedObjectContext *)context;

+ (id)findFirstInContext:(NSManagedObjectContext *)context;
+ (id)findFirstWithPredicate:(NSPredicate *)predicate
                   inContext:(NSManagedObjectContext *)context;

+ (NSInteger)deleteAllInContext:(NSManagedObjectContext *)context;

@end


@interface NSManagedObject (LokaliteHelpers)

+ (id)instanceWithIdentifier:(id)identifier
                   inContext:(NSManagedObjectContext *)context;

+ (id)existingOrNewInstanceWithIdentifier:(id)identifier
                                inContext:(NSManagedObjectContext *)context;

@end
