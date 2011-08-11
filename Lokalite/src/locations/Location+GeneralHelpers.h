//
//  Location+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Location.h"

@class LokaliteDownloadSource;

@interface Location (GeneralHelpers)

#pragma mark - Lifecycle

//
// Deletes the receiver if all of its relationships are empty; that is, if no
// objects are referencing it any longer.
//
- (BOOL)deleteIfAppropriate;

#pragma mark - Convenience methods

- (NSURL *)addressUrl;

#pragma mark - Creating and finding instances

+ (id)existingOrNewLocationFromJsonData:(NSDictionary *)jsonData
                         downloadSource:(LokaliteDownloadSource *)source
                              inContext:(NSManagedObjectContext *)context;

@end
