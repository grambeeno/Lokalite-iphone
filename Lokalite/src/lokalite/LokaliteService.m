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

@property (nonatomic, copy) NSString *email;
@property (nonatomic, copy) NSString *password;

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

@synthesize email = email_;
@synthesize password = password_;

#pragma mark - Memory management

- (void)dealloc
{
    [baseUrl_ release];

    [email_ release];
    [password_ release];
    
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url
{
    self = [super init];
    if (self)
        baseUrl_ = [url copy];

    return self;
}

#pragma mark - Authentication

- (void)fetchProfileWithResponseHandler:(LSResponseHandler)handler
{
    [self sendRequestWithUrl:[self profileUrl]
                  parameters:nil
               requestMethod:LKRequestMethodGET
             responseHandler:handler];
}

- (void)setEmail:(NSString *)email password:(NSString *)password
{
    [self setEmail:email];
    [self setPassword:password];
}

- (void)removeEmailAndPassword
{
    [self setEmail:nil password:nil];
}

#pragma mark - Events

- (void)fetchFeaturedEventsWithResponseHandler:(LSResponseHandler)handler
{
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

    NSString *email = [self email], *password = [self password];
    if (email && password)
        [req authenticateWithUsername:email password:password];

    [req performRequestWithHandler:
     ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
         id processedData = nil;
         if ([response statusCode] == 200) {
             if (data) {
                 NSError *error = nil;
                 processedData = [self processJsonData:data error:&error];
             }
         } else
             error = [NSError errorForHTTPStatusCode:[response statusCode]];

         handler(processedData, error);
     }];
}

#pragma mark - Processing response data

- (id)processJsonData:(NSData *)data error:(NSError **)error
{
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
