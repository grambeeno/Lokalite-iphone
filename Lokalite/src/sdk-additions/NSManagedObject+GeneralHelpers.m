//
//  NSManagedObject+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "NSManagedObject+GeneralHelpers.h"

@implementation NSManagedObject (GeneralHelpers)

+ (id)createInstanceInContext:(NSManagedObjectContext *)context
{
    NSString * className = NSStringFromClass(self);
    return [NSEntityDescription insertNewObjectForEntityForName:className
                                         inManagedObjectContext:context];
}

+ (NSArray *)findAllInContext:(NSManagedObjectContext *)context
{
    return [self findAllWithPredicate:nil inContext:context];
}

+ (NSArray *)findAllInObjectIdsContext:(NSManagedObjectContext *)context
{
    return [self findAllWithPredicate:nil
                           fetchLimit:0
                           resultType:NSManagedObjectIDResultType
                            inContext:context];
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate
                        inContext:(NSManagedObjectContext *)context
{
    return [self findAllWithPredicate:predicate fetchLimit:0 inContext:context];
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate
                       fetchLimit:(NSInteger)fetchLimit
                        inContext:(NSManagedObjectContext *)context
{
    return [self findAllWithPredicate:predicate
                           fetchLimit:fetchLimit
                           resultType:NSManagedObjectResultType
                            inContext:context];
}

+ (NSArray *)findAllWithPredicate:(NSPredicate *)predicate
                       fetchLimit:(NSInteger)fetchLimit
                       resultType:(NSFetchRequestResultType)resultType
                        inContext:(NSManagedObjectContext *)context
{
    NSString * className = NSStringFromClass(self);
    NSEntityDescription * entity =
        [NSEntityDescription entityForName:className
                    inManagedObjectContext:context];

    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    [request setFetchLimit:fetchLimit];
    [request setResultType:resultType];

    NSError *error = nil;
    NSArray * results = [context executeFetchRequest:request error:&error];

    [request release];

    return results;
}

+ (id)findFirstWithPredicate:(NSPredicate *)predicate
                   inContext:(NSManagedObjectContext *)context
{
    NSArray *a = [self findAllWithPredicate:predicate
                                 fetchLimit:1
                                  inContext:context];
    return [a count] > 0 ? [a objectAtIndex:0] : nil;
}

@end
