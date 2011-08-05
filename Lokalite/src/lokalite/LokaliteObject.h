//
//  LokaliteObject.h
//  Lokalite
//
//  Created by John Debay on 8/5/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LokaliteDownloadSource;

@interface LokaliteObject : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSSet *downloadSources;
@end

@interface LokaliteObject (CoreDataGeneratedAccessors)

- (void)addDownloadSourcesObject:(LokaliteDownloadSource *)value;
- (void)removeDownloadSourcesObject:(LokaliteDownloadSource *)value;
- (void)addDownloadSources:(NSSet *)values;
- (void)removeDownloadSources:(NSSet *)values;
@end
