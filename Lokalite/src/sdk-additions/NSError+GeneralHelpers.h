//
//  NSError+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (GeneralHelpers)

- (NSString *)detailedDescription;

+ (id)unknownError;

@end


@interface NSError (HTTPHelpers)

+ (id)errorForHTTPStatusCode:(NSInteger)statusCode;

@end
