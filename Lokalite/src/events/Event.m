//
//  Event.m
//  Lokalite
//
//  Created by John Debay on 8/15/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import "Event.h"
#import "Business.h"
#import "Category.h"
#import "Location.h"

#import "Event+GeneralHelpers.h"
#import "Location+GeneralHelpers.h"
#import "LokaliteObjectMapAnnotation.h"
#import "UIApplication+GeneralHelpers.h"

@implementation Event
@dynamic summary;
@dynamic endDate;
@dynamic dateDescription;
@dynamic startDate;
@dynamic trended;
@dynamic featured;
@dynamic trendWeight;
@dynamic fullImageUrl;
@dynamic fullImageData;
@dynamic name;
@dynamic distance;
@dynamic distanceDescription;
@dynamic largeImageUrl;
@dynamic thumbnailImageUrl;
@dynamic mediumImageUrl;
@dynamic smallImageUrl;
@dynamic thumbnailImageData;
@dynamic largeImageData;
@dynamic mediumImageData;
@dynamic smallImageData;
@dynamic location;
@dynamic categories;
@dynamic business;

#pragma mark - LokaliteObject implementation

- (UIImage *)mapAnnotationViewImage
{
    return [self standardImage];
}

- (id<MKAnnotation>)mapAnnotation
{
    return [[[LokaliteObjectMapAnnotation alloc]
             initWithCoordinate:[[self locationInstance] coordinate]
                          title:[self name]
                       subtitle:[self summary]
                         object:self]
            autorelease];
}

- (NSURL *)addressUrl
{
    return [[self location] addressUrl];
}

- (NSURL *)directionsUrlFromLocation:(CLLocation *)location
{
    return [[self location] urlForDirectionsFromLocation:location];
}

- (NSString *)pluralTitle
{
    NSString *format =
        NSLocalizedString(@"annotation.grouped.events.title.format", nil);
    return [NSString stringWithFormat:format, [[self business] name]];
}

#pragma mark - ShareableObject implementation

#pragma mark Web

- (NSURL *)lokaliteUrl
{
    NSURL *url = [[UIApplication sharedApplication] baseLokaliteUrl];
    url = [url URLByAppendingPathComponent:@"events"];

    return [url URLByAppendingPathComponent:[[self identifier] description]];
}

#pragma mark Email

- (NSString *)emailSubject
{
    return NSLocalizedString(@"event.share.email.subject", nil);
}

- (NSString *)emailHTMLBody
{
    NSMutableString *s =
        [NSMutableString stringWithFormat:@"<p>%@</p><p><a href=\"%@\">%@</a> "
         "at %@</p>", NSLocalizedString(@"event.share.email.body.prefix", nil),
         [[self lokaliteUrl] absoluteString], [self name],
         [[self business] name]];

    return s;
}

#pragma mark SMS

- (NSString *)smsBody
{
    NSMutableString *s =
        [NSMutableString stringWithString:
         NSLocalizedString(@"event.share.sms.body.prefix", nil)];
    [s appendFormat:@"\n\n%@ at %@\n\n%@", [self name], [[self business] name],
     [[self lokaliteUrl] absoluteString]];

    return s;
}

#pragma mark Facebook

- (NSString *)facebookName
{
    return [self name];
}

- (NSURL *)facebookImageUrl
{
    return [NSURL URLWithString:[self standardImageUrl]];
}

- (NSString *)facebookCaption
{
    return [NSString stringWithFormat:@"@ %@", [[self business] name]];
}

- (NSString *)facebookDescription
{
    return [self summary];
}

#pragma mark - Twitter

- (NSString *)twitterText
{
    NSURL *url = [self lokaliteUrl];
    NSString *s =
        [NSString stringWithFormat:@"%@ at %@\n\n%@", [self name],
         [[self business] name], [url absoluteString]];

    return s;
}

@end
