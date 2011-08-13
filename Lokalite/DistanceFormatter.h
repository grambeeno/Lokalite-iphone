//
//  Copyright High Order Bit, Inc. 2010. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "UnitsSetting.h"

typedef double (^distance_converter_fun_t)(double);

@interface DistanceFormatter : NSObject
{
    NSNumberFormatter * formatter;
    double threshold;
    NSString * majorUnit;
    NSString * minorUnit;
    distance_converter_fun_t distanceConverter;
}

#pragma mark Instantiation and initialization

+ (id)formatterFromUserDefaults;
+ (id)formatterWithSetting:(UnitsSetting)setting;

#pragma mark Initialization

- (id)initWithSetting:(UnitsSetting)setting;

#pragma mark Converting distance values to strings

- (NSString *)distanceAsString:(CLLocationDistance)distance;

@end
