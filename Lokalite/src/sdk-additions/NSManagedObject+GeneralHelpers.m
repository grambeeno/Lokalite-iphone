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
    return [self findFirstWithPredicate:nil inContext:context];
}

+ (id)findAllWithPredicate:(NSPredicate *)predicate
                 inContext:(NSManagedObjectContext *)context
{
    NSString * className = NSStringFromClass(self);
    NSEntityDescription * entity =
        [NSEntityDescription entityForName:className
                    inManagedObjectContext:context];

    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];

    NSError *error = nil;
    NSArray * results = [context executeFetchRequest:request error:&error];

    [request release];

    return results;
}

+ (id)findFirstWithPredicate:(NSPredicate *)predicate
                   inContext:(NSManagedObjectContext *)context
{
    NSArray *a = [self findAllWithPredicate:predicate inContext:context];
    return [a count] > 0 ? [a objectAtIndex:0] : nil;
}

@end
