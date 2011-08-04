//
//  LokaliteObject.h
//  Lokalite
//
//  Created by John Debay on 8/4/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LokaliteObject : NSManagedObject {
@private
}
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSDate * updatedTime;

@end
