//
//  Event.h
//  Lokalite
//
//  Created by John Debay on 7/27/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Business, Category, Venue;

@interface Event : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * summary;
@property (nonatomic, retain) NSDate * endDate;
@property (nonatomic, retain) NSDate * startDate;
@property (nonatomic, retain) NSNumber * featured;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSNumber * identifier;
@property (nonatomic, retain) NSData * imageData;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * trended;
@property (nonatomic, retain) Category *category;
@property (nonatomic, retain) Venue *venue;
@property (nonatomic, retain) Business *business;

@end
