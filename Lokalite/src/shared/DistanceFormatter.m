//
//  DistanceFormatter.m
//  Lokalite
//
//  Created by John Debay on 8/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "DistanceFormatter.h"
#import "Constants.h"

@interface DistanceFormatter ()
@property (nonatomic, retain) NSNumberFormatter * formatter;
@property (nonatomic, assign) double threshold;
@property (nonatomic, copy) NSString * majorUnit;
@property (nonatomic, copy) NSString * minorUnit;
@property (nonatomic, copy) DFDistanceConverter distanceConverter;

- (id)initWithMajorUnit:(NSString *)aMajorUnit
              minorUnit:(NSString *)aMinorUnit
              threshold:(double)aThreshold
              converter:(DFDistanceConverter)converter;
@end

@implementation DistanceFormatter

@synthesize formatter, threshold, majorUnit, minorUnit;
@synthesize distanceConverter;

#pragma mark -
#pragma mark Memory management

- (void)dealloc
{
    [self setFormatter:nil];
    [self setMajorUnit:nil];
    [self setMinorUnit:nil];
    [self setDistanceConverter:nil];

    [super dealloc];
}

#pragma mark -
#pragma mark Instantiation and initialization

+ (id)formatter
{
    id obj = nil;

    /*
    if (setting == kUnitsSettingMetric)
        obj = [[self alloc] initWithMajorUnit:@"km"
                                    minorUnit:@"m"
                                    threshold:1000
                                    converter:^(double distance) {
                                          return distance;
                                      }];
    else if (setting == kUnitsSettingEnglish)
     */
        obj = [[self alloc] initWithMajorUnit:@"mi"
                                    minorUnit:@"ft"
                                    threshold:/*5280*/ 0
                                    converter:^(double distance) {
                                        return distance * 3.280839895013;
                                    }];

    return [obj autorelease];
}

#pragma mark -
#pragma mark Initialization

- (id)initWithMajorUnit:(NSString *)aMajorUnit
              minorUnit:(NSString *)aMinorUnit
              threshold:(double)aThreshold
              converter:(DFDistanceConverter)converter
{
    if (self = [super init]) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setLocale:[NSLocale currentLocale]];

        [self setMajorUnit:aMajorUnit];
        [self setMinorUnit:aMinorUnit];
        [self setThreshold:aThreshold];
        [self setDistanceConverter:converter];
    }

    return self;
}

- (id)init
{
    if (self = [super init]) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter setLocale:[NSLocale currentLocale]];

        /*
        if (setting == kUnitsSettingMetric) {
            [self setThreshold:1000];
            [self setMajorUnit:@"km"];
            [self setMinorUnit:@"m"];
            [self setDistanceConverter:^(double distance) { return distance; }];
        } else if (setting == kUnitsSettingEnglish) {
         */
            [self setThreshold:FEET_PER_MILE];
            [self setMajorUnit:@"mi"];
            [self setMinorUnit:@"ft"];
            [self setDistanceConverter:
                // convert meters to feet
                ^(double distance) { return distance * FEET_PER_METER; }];
        /*
        }
         */
    }

    return self;
}

#pragma mark -
#pragma mark Converting distance values to strings

- (NSString *)distanceAsString:(CLLocationDistance)originalDistance
{
    CLLocationDistance distance = distanceConverter(originalDistance);

    NSString * val = nil;
    NSString * unit = nil;

    if ([self threshold] > 0 && distance > [self threshold]) {
        NSInteger major = (NSInteger) distance / [self threshold];
        NSInteger minor = (NSInteger) distance % (int) [self threshold];
        NSString * tmp = [NSString stringWithFormat:@"%d.%d", major, minor];
        double d = [tmp doubleValue];
        NSNumber * n = [NSNumber numberWithDouble:d];

        [[self formatter] setMaximumFractionDigits:1];

        val = [[self formatter] stringFromNumber:n];
        unit = [self majorUnit];
    } else {
        [formatter setMaximumFractionDigits:0];
        NSNumber * n = [NSNumber numberWithDouble:distance];
        val = [[self formatter] stringFromNumber:n];
        unit = [self minorUnit];
    }

    return [NSString stringWithFormat:@"%@ %@", val, unit];
}

@end
