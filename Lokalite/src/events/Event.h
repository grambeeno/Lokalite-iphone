//
//  Event.h
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface Event : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSManagedObject *business;

@end
