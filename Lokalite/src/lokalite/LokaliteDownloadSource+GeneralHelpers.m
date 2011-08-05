//
//  LokaliteDownloadSource+GeneralHelpers.m
//  Lokalite
//
//  Created by John Debay on 8/5/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteDownloadSource+GeneralHelpers.h"
#import "NSManagedObject+GeneralHelpers.h"

@implementation LokaliteDownloadSource (GeneralHelpers)

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

/*
+ (id)downloadSourceFromAPIParams:(NSDictionary *)apiParams
                        inContext:(NSManagedObjectContext *)context
{
    NSString *category = [apiParams objectForKey:@"category"];
    NSString *path = [apiParams objectForKey:@"path"];
    NSString *name =
        [NSString stringWithFormat:@"%@?category=%@", path, category];

    LokaliteDownloadSource *source =
        [self downloadSourceWithName:name inContext:context];
    if (!source) {
        source = [LokaliteDownloadSource createInstanceInContext:context];
        [source setName:name];
    }

    return source;
}
 */

@end
