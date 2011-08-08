//
//  LokaliteObject+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 8/5/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteObject+GeneralHelpers.h"
#import "LokaliteDownloadSource.h"
#import "NSManagedObject+GeneralHelpers.h"

@implementation LokaliteObject (GeneralHelpers)

#pragma mark - NSManagedObject implementation

- (void)prepareForDeletion
{
    NSManagedObjectContext *context = [self managedObjectContext];

    NSSet *downloadSources = [self downloadSources];
    [downloadSources enumerateObjectsUsingBlock:
     ^(LokaliteDownloadSource *source, BOOL *stop) {
         [source removeLokaliteObjectsObject:self];
         if ([[source lokaliteObjects] count] == 0)
             [context deleteObject:source];
     }];

    [super prepareForDeletion];
}

#pragma mark - Helping with download sources

- (LokaliteDownloadSource *)addDownloadSourceWithName:(NSString *)name
{
    LokaliteDownloadSource *source = [self downloadSourceWithName:name];
    if (!source) {
        NSManagedObjectContext *context = [self managedObjectContext];
        source = [LokaliteDownloadSource createInstanceInContext:context];
        [source setName:name];
    }

    return source;
}

- (LokaliteDownloadSource *)downloadSourceWithName:(NSString *)name
{
    NSManagedObjectContext *context = [self managedObjectContext];
    NSPredicate *predicate =
        [NSPredicate predicateWithFormat:
         @"lokaliteObjects == %@ AND name == %@", self, name];

    return [LokaliteDownloadSource findFirstWithPredicate:predicate
                                                inContext:context];
}

- (LokaliteDownloadSource *)setLastUpdatedDate:(NSDate *)date
                            fromDownloadSource:(NSString *)downloadSource
{
    LokaliteDownloadSource *source =
        [self downloadSourceWithName:downloadSource];
    if (!source) {
        NSManagedObjectContext *context = [self managedObjectContext];
        source = [LokaliteDownloadSource createInstanceInContext:context];
        [self addDownloadSourcesObject:source];
    }

    [source setName:downloadSource];
    [source setLastUpdated:date];

    return source;
}

@end
