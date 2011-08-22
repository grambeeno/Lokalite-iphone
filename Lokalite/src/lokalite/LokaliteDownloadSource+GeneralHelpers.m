//
//  LokaliteDownloadSource+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 8/5/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteDownloadSource+GeneralHelpers.h"
#import "NSManagedObject+GeneralHelpers.h"

#import "LokaliteObject.h"

@implementation LokaliteDownloadSource (GeneralHelpers)

- (void)unassociateAndDeleteDownloadedObjects
{
    [self unassociateAndDeleteDownloadedObjectsDeletingIfEmpty:YES];
}

- (void)unassociateAndDeleteDownloadedObjectsDeletingIfEmpty:(BOOL)deleteIfEmpty
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSSet *objects = [[self lokaliteObjects] mutableCopy];
    [objects enumerateObjectsUsingBlock:^(LokaliteObject *obj, BOOL *stop) {
        [obj removeDownloadSourcesObject:self];
        if ([[obj downloadSources] count] == 0) {
            NSLog(@"Deleting %@ %@", NSStringFromClass([obj class]),
                  [obj identifier]);
            [context deleteObject:obj];
        }
    }];
    [objects release], objects = nil;

    if (deleteIfEmpty && [[self lokaliteObjects] count] == 0)
        [context deleteObject:self];
}

#pragma mark - Creating and finding

+ (id)downloadSourceWithName:(NSString *)name
                   inContext:(NSManagedObjectContext *)context
           createIfNecessary:(BOOL)createIfNecessary
{
    LokaliteDownloadSource *source =
        [LokaliteDownloadSource downloadSourceWithName:name inContext:context];
    if (createIfNecessary && !source) {
        source = [LokaliteDownloadSource createInstanceInContext:context];
        [source setName:name];
    }

    return source;
}

+ (id)downloadSourceWithName:(NSString *)name
                   inContext:(NSManagedObjectContext *)context
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"name == %@", name];
    return [self findFirstWithPredicate:pred inContext:context];
}

@end
