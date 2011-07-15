//
//  Event.h
//  Lokalite
//
//  Created by John Debay on 7/15/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Business, Venue;

@interface Event : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) Business *business;
@property (nonatomic, retain) Venue *venue;

@end
