//
//  LokaliteDataParser.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

@interface LokaliteDataParser : NSObject

+ (id)parseLokaliteData:(NSData *)data error:(NSError **)error;

@end
