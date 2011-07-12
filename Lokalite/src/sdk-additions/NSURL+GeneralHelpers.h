//
//  NSURL+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURL (GeneralHelpers)

- (NSURL *)URLByAppendingGetParameters:(NSDictionary *)params;

@end
