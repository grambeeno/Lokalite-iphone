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

+ (id)textRangeWithStartDate:(NSDate *)startDate endDate:(NSDate *)endDate;
+ (id)stringFromLocationDistance:(CLLocationDistance)distance;

@end


@interface NSString (LokaliteHelpers)

- (NSArray *)arrayByTokenizingWithString:(NSString *)token;

@end
