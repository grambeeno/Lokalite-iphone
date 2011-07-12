//
//  LokaliteDataParser.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteDataParser.h"
#import "JSONKit.h"

@implementation LokaliteDataParser

+ (id)parseLokaliteData:(NSData *)data error:(NSError **)error
{
    return [[JSONDecoder decoder] objectWithData:data error:error];
}

@end
