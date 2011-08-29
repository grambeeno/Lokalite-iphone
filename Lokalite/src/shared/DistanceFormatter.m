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
@property (nonatomic, retain) NSNumberFormatter *formatter;
@end

@implementation DistanceFormatter

@synthesize formatter = formatter_;

#pragma mark - Memory management

- (void)dealloc
{
    [formatter_ release];

    [super dealloc];
}

#pragma mark -
#pragma mark - Instantiation and initialization

+ (id)formatter
{
    return [[[self alloc] init] autorelease];
}

#pragma mark - Converting distance values to strings

- (NSString *)distanceAsString:(CLLocationDistance)distanceInMeters
{
    CLLocationDistance distanceInFeet = distanceInMeters * FEET_PER_METER;
    CLLocationDistance distanceInMiles = distanceInFeet / FEET_PER_MILE;
    NSNumber *distance = [NSNumber numberWithDouble:distanceInMiles];

    [[self formatter] setMaximumFractionDigits:2];
    NSString *distanceString = [[self formatter] stringFromNumber:distance];

    return [NSString stringWithFormat:@"%@ mi", distanceString];
}

#pragma mark - Accessors

- (NSNumberFormatter *)formatter
{
    if (!formatter_) {
        formatter_ = [[NSNumberFormatter alloc] init];
        [formatter_ setFormatterBehavior:NSNumberFormatterBehavior10_4];
        [formatter_ setNumberStyle:NSNumberFormatterDecimalStyle];
        [formatter_ setLocale:[NSLocale currentLocale]];
    }

    return formatter_;
}

@end



@implementation DistanceFormatter (LokaliteHelpers)

+ (NSString *)sectionDescriptionForDistance:(CLLocationDistance)distance
{
    static const CLLocationDistance WALKING_DISTANCE = 1609.344;  // 1 mile
    static const CLLocationDistance BIKING_DISTANCE = 1609.344 * 5;
    static const CLLocationDistance DRIVING_DISTANCE = 1609.344 * 150;

    NSString *description = nil;
    if (distance < WALKING_DISTANCE)
        description = NSLocalizedString(@"distance.walking-distance", nil);
    else if (distance < BIKING_DISTANCE)
        description = NSLocalizedString(@"distance.driving-distance", nil);
    else if (distance < DRIVING_DISTANCE)
        description = NSLocalizedString(@"distance.driving-distance", nil);
    else
        description = NSLocalizedString(@"distance.flying-distance", nil);

    return description;
}

@end
