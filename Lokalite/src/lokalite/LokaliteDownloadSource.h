//
//  LokaliteDownloadSource.h
//  Lokalite
//
//  Created by John Debay on 8/5/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class LokaliteObject;

@interface LokaliteDownloadSource : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * lastUpdated;
@property (nonatomic, retain) NSSet *lokaliteObjects;
@end

@interface LokaliteDownloadSource (CoreDataGeneratedAccessors)

- (void)addLokaliteObjectsObject:(LokaliteObject *)value;
- (void)removeLokaliteObjectsObject:(LokaliteObject *)value;
- (void)addLokaliteObjects:(NSSet *)values;
- (void)removeLokaliteObjects:(NSSet *)values;
@end
