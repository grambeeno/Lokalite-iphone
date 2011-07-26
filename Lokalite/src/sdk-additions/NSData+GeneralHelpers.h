//
//  NSData+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/26/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (GeneralHelpers)

- (NSString *) base64EncodingWithLineLength:(unsigned int) lineLength;

@end
