//
//  LokaliteObjectBuilder.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@class NSManagedObjectContext;

@interface LokaliteObjectBuilder : NSObject

+ (NSArray *)buildEventsFromJsonArray:(NSArray *)jsonObjects
                            inContext:(NSManagedObjectContext *)context;

@end
