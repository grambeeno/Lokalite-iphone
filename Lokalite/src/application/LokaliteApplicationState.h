//
//  ApplicationState.h
//  Lokalite
//
//  Created by John Debay on 8/4/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface LokaliteApplicationState : NSManagedObject {
@private
}
@property (nonatomic, retain) NSDate * dataFreshnessDate;

@end
