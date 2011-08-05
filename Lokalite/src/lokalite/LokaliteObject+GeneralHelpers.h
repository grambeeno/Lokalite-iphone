//
//  LokaliteObject+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 8/5/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteObject.h"

@class LokaliteDownloadSource;

@interface LokaliteObject (GeneralHelpers)

- (LokaliteDownloadSource *)addDownloadSourceWithName:(NSString *)name;

- (LokaliteDownloadSource *)downloadSourceWithName:(NSString *)name;

- (LokaliteDownloadSource *)setLastUpdatedDate:(NSDate *)date
                            fromDownloadSource:(NSString *)downloadSource;

@end
