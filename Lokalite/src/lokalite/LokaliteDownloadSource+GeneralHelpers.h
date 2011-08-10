//
//  LokaliteDownloadSource+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 8/5/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteDownloadSource.h"

@interface LokaliteDownloadSource (GeneralHelpers)

- (void)unassociateAndDeleteDownloadedObjects;

#pragma mark - Creating and finding

+ (id)downloadSourceWithName:(NSString *)name
                   inContext:(NSManagedObjectContext *)context
           createIfNecessary:(BOOL)createIfNecessary;

+ (id)downloadSourceWithName:(NSString *)name
                   inContext:(NSManagedObjectContext *)context;

@end
