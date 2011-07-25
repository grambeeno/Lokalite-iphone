//
//  LokaliteService.m
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteService.h"
#import "LokaliteServiceRequest.h"

#import "Event.h"

#import "LokaliteDataParser.h"

#import "SDKAdditions.h"

@interface LokaliteService ()

#pragma mark - Sending requests

- (void)sendRequestWithUrl:(NSURL *)url
                parameters:(NSDictionary *)parameters
             requestMethod:(LKRequestMethod)requestMethod
           responseHandler:(LSResponseHandler)handler;

#pragma mark - Processing JSON data

- (id)processJsonData:(NSData *)data error:(NSError **)error;
@end

@implementation LokaliteService

@synthesize baseUrl = baseUrl_;

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url
{
    self = [super init];
    if (self)
        baseUrl_ = [url copy];

    return self;
}

#pragma mark - Authentication

- (void)fetchProfileForUsername:(NSString *)username
                       password:(NSString *)password
                responseHandler:(LSResponseHandler)handler
{
    NSURL *url = [self profileUrl];
    NSDictionary *parameters =
        [NSDictionary dictionaryWithObjectsAndKeys:
         username, @"username", password, @"password", nil];

    [self sendRequestWithUrl:url
                  parameters:parameters
               requestMethod:LKRequestMethodGET
             responseHandler:handler];
}

#pragma mark - Events

- (void)fetchFeaturedEventsWithResponseHandler:(LSResponseHandler)handler
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSURL *url = [self featuredEventUrl];

    [self sendRequestWithUrl:url
                  parameters:nil
               requestMethod:LKRequestMethodGET
             responseHandler:handler];
}

- (void)fetchEventsWithCategory:(NSString *)category
                responseHandler:(LSResponseHandler)handler
{
    NSURL *url = [self featuredEventUrl];
    NSDictionary *params =
        category ?
        [NSDictionary dictionaryWithObject:category forKey:@"category"] :
        nil;

    [self sendRequestWithUrl:url
                  parameters:params
               requestMethod:LKRequestMethodGET
             responseHandler:handler];
}

#pragma mark - Places

- (void)fetchPlacesWithCategory:(NSString *)category
                responseHandler:(LSResponseHandler)handler
{
    [self sendRequestWithUrl:[self placesUrl]
                  parameters:nil
               requestMethod:LKRequestMethodGET
             responseHandler:handler];
}

#pragma mark - Search

- (void)searchForKeywords:(NSArray *)keywords
            includeEvents:(BOOL)includeEvents
        includeBusinesses:(BOOL)includeBusinesses
          responseHandler:(LSResponseHandler)handler
{
    NSLog(@"Searching for keywords: '%@', include events: %@, include "
          "businesses: %@", keywords, includeEvents ? @"YES" : @"NO",
          includeBusinesses ? @"YES" : @"NO");

    NSURL *url = [self featuredEventUrl];
    NSDictionary *parameters =
        [NSDictionary dictionaryWithObject:
         [keywords componentsJoinedByString:@" "] forKey:@"keywords"];
    LokaliteServiceRequest *req =
        [[LokaliteServiceRequest alloc] initWithUrl:url
                                         parameters:parameters
                                      requestMethod:LKRequestMethodGET];
    [req performRequestWithHandler:
     ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        if (data) {
             NSError *error = nil;
             id object = [self processJsonData:data error:&error];
             handler(object, error);
         } else
             handler(nil, error);
     }];
}

#pragma mark - Sending requests

- (void)sendRequestWithUrl:(NSURL *)url
                parameters:(NSDictionary *)parameters
             requestMethod:(LKRequestMethod)requestMethod
           responseHandler:(LSResponseHandler)handler
{
    LokaliteServiceRequest *req =
        [[LokaliteServiceRequest alloc] initWithUrl:url
                                         parameters:parameters
                                      requestMethod:LKRequestMethodGET];
    [req performRequestWithHandler:
     ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
         if (data) {
             NSError *error = nil;
             id object = [self processJsonData:data error:&error];
             handler(object, error);
         } else
             handler(nil, error);
     }];
}

#pragma mark - Processing response data

- (id)processJsonData:(NSData *)data error:(NSError **)error
{
    /* Removing mock data placeholder because it's not needed
    if ([data length] == 1) {
        NSLog(@"WARNING: nothing received from server; using mock data");
        NSURL *hackedFileUrl =
            [[NSBundle mainBundle] URLForResource:@"mock-featured-events"
                                    withExtension:@"json"];
        data = [NSData dataWithContentsOfURL:hackedFileUrl
                                     options:0
                                       error:NULL];
    } else {
        NSString *docsDir = [UIApplication applicationDocumentsDirectory];
        NSString *path =
            [docsDir stringByAppendingPathComponent:
             @"mock-featured-events.json"];
        NSURL *hackedFileUrl = [NSURL fileURLWithPath:path];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path])
            [data writeToURL:hackedFileUrl
                     options:NSDataWritingAtomic
                       error:NULL];
    }
     */

    return [LokaliteDataParser parseLokaliteData:data error:error];
}

#pragma mark - URLs

- (NSURL *)profileUrl
{
    return [[self baseUrl] URLByAppendingPathComponent:@"api/profile"];
}

- (NSURL *)featuredEventUrl
{
    return [[self baseUrl] URLByAppendingPathComponent:@"api/events/browse"];
}

- (NSURL *)placesUrl
{
    return
        [[self baseUrl]
         URLByAppendingPathComponent:@"api/organizations/browse"];
}

@end
