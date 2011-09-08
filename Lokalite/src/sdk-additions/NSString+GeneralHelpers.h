//
//  NSString+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/14/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface NSString (GeneralHelpers)

+ (id)stringFromLocationDistance:(CLLocationDistance)distance;

- (NSString *)formattedPhoneNumberString;

@end


@interface NSString (LokaliteHelpers)

- (NSArray *)arrayByTokenizingWithString:(NSString *)token;

@end
