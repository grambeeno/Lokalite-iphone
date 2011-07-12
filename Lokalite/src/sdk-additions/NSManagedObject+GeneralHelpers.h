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
+ (id)findAllWithPredicate:(NSPredicate *)predicate
                 inContext:(NSManagedObjectContext *)context;

+ (id)findFirstWithPredicate:(NSPredicate *)predicate
                   inContext:(NSManagedObjectContext *)context;

@end
