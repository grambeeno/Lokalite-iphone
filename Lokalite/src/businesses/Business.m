//
//  Business.m
//  Lokalite
//
//  Created by John Debay on 8/15/11.
//  Copyright (c) 2011 Lokalite. All rights reserved.
//

#import "Business.h"
#import "Category.h"
#import "Event.h"
#import "Location.h"

#import "Business+GeneralHelpers.h"
#import "Location+GeneralHelpers.h"
#import "LokaliteObjectMapAnnotation.h"
#import "UIApplication+GeneralHelpers.h"

@implementation Business
@dynamic phone;
@dynamic summary;
@dynamic fullImageUrl;
@dynamic url;
@dynamic name;
@dynamic distance;
@dynamic distanceDescription;
@dynamic fullImageData;
@dynamic largeImageUrl;
@dynamic largeImageData;
@dynamic mediumImageUrl;
@dynamic mediumImageData;
@dynamic smallImageUrl;
@dynamic smallImageData;
@dynamic thumbnailImageUrl;
@dynamic thumbnailImageData;
@dynamic events;
@dynamic categories;
@dynamic location;

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
    return NSLocalizedString(@"annotation.grouped.places.title.format", nil);
}

#pragma mark - ShareableObject implementation

#pragma mark Web

- (NSURL *)lokaliteUrl
{
    NSURL *url = [[UIApplication sharedApplication] baseLokaliteUrl];
    url = [url URLByAppendingPathComponent:@"places"];

    return [url URLByAppendingPathComponent:[[self identifier] description]];
}

#pragma mark Email

- (NSString *)emailSubject
{
    return NSLocalizedString(@"place.share.email.subject", nil);
}

- (NSString *)emailHTMLBody
{
    NSMutableString *s =
        [NSMutableString stringWithFormat:@"<p>%@</p>", [self name]];

    NSString *link = [[self lokaliteUrl] absoluteString];
    NSString *linkTitle =
        NSLocalizedString(@"place.share.email.link-text", nil);
    [s appendFormat:@"<p><a href=\"%@\">%@</a></p>", link, linkTitle];

    return s;
}

#pragma mark SMS

- (NSString *)smsBody
{
    NSMutableString *s =
        [NSMutableString stringWithString:
         NSLocalizedString(@"place.share.sms.body.prefix", nil)];
    [s appendFormat:@"\n\n%@\n\n%@", [self name],
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
    return @"";
}

- (NSString *)facebookDescription
{
    return [self summary];
}

#pragma mark - Twitter

- (NSString *)twitterText
{
    NSURL *url = [self lokaliteUrl];
    NSMutableString *s =
        [NSMutableString stringWithString:
         NSLocalizedString(@"place.share.twitter.body.prefix", nil)];
    [s appendFormat:@"\n\n%@\n\n%@",
         [self name], [url absoluteString]];

    return s;
}

@end
