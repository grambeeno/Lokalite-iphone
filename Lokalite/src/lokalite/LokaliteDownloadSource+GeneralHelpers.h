//
//  LokaliteDownloadSource+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 8/5/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteDownloadSource.h"

@interface LokaliteDownloadSource (GeneralHelpers)

//
// Sends -unassociateAndDeleteDownloadedObjects: to the receiver with
// deleteIfEmpty set to YES.
//
- (void)unassociateAndDeleteDownloadedObjects;

//
// Unassociate all LokaliteObjects from the receiver. If a LokaliteObject has
// the receiver as its only associated download source, delete the
// LokaliteObject. If deleteIfEmpty is YES, the receiver deletes itself after
// completing the operation if it is no longer associated with any
// LokaliteObjects.
//
- (void)unassociateAndDeleteDownloadedObjectsDeletingIfEmpty:(BOOL)deleteIfEmpty
;

#pragma mark - Creating and finding

+ (id)downloadSourceWithName:(NSString *)name
                   inContext:(NSManagedObjectContext *)context
           createIfNecessary:(BOOL)createIfNecessary;

+ (id)downloadSourceWithName:(NSString *)name
                   inContext:(NSManagedObjectContext *)context;

@end
