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

- (void)fetchEventsWithCategory:(NSString *)category
                   nearLocation:(CLLocationCoordinate2D)location
                       fromPage:(NSInteger)page
                 objectsPerPage:(NSInteger)objectsPerPage
                responseHandler:(LSResponseHandler)handler
{
    NSURL *url = [self featuredEventUrl];

    NSMutableDictionary *params =
        [NSMutableDictionary
         dictionaryWithObjectsAndKeys:
         [NSString stringWithFormat:@"%d", page], @"page",
         [NSString stringWithFormat:@"%d", objectsPerPage], @"per_page",
         nil];

    if (!category)
        category = @"";
    [params setObject:category forKey:@"category"];

    if (CLLocationCoordinate2DIsValid(location)) {
        NSString *origin = [NSString stringWithFormat:@"%f,%f",
                            location.latitude, location.longitude];
        [params setObject:origin forKey:@"origin"];
    }

    [self sendRequestWithUrl:url
                  parameters:params
               requestMethod:LKRequestMethodGET
             responseHandler:handler];
}

#pragma mark - Trending events

- (void)trendEventWithEventId:(NSNumber *)eventId
              responseHandler:(LSResponseHandler)handler
{
    NSURL *url = [self trendUrl];
    NSDictionary *params =
        [NSDictionary dictionaryWithObject:[eventId description]
                                    forKey:@"event_id"];
    [self sendRequestWithUrl:url
                  parameters:params
               requestMethod:LKRequestMethodPOST
             responseHandler:handler];
}

- (void)untrendEventWithEventId:(NSNumber *)eventId
                responseHandler:(LSResponseHandler)handler
{
    NSURL *url = [self untrendUrl];
    NSDictionary *params =
        [NSDictionary dictionaryWithObject:[eventId description]
                                    forKey:@"event_id"];
    [self sendRequestWithUrl:url
                  parameters:params
               requestMethod:LKRequestMethodPOST
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

- (void)performSearchForKeywords:(NSString *)keywords
                             url:(NSURL *)url
                 responseHandler:(LSResponseHandler)handler
{
    NSString *encodedKeywords =
        [keywords
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *parameters =
        [NSDictionary dictionaryWithObject:encodedKeywords
                                    forKey:@"keywords"];
    LokaliteServiceRequest *req =
        [[LokaliteServiceRequest alloc] initWithUrl:url
                                         parameters:parameters
                                      requestMethod:LKRequestMethodGET];
    [req performRequestWithHandler:
     ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
        if (data) {
             NSError *error = nil;
             id object = [self processJsonData:data error:&error];
             handler(response, object, error);
         } else
             handler(response, nil, error);

         [req release];
     }];
}

- (void)searchEventsForKeywords:(NSString *)keywords
                responseHandler:(LSResponseHandler)handler
{
    NSLog(@"Searching events for keywords: '%@'", keywords);
    [self performSearchForKeywords:keywords
                               url:[self featuredEventUrl]
                   responseHandler:handler];
}

- (void)searchPlacesForKeywords:(NSString *)keywords
                responseHandler:(LSResponseHandler)handler
{
    NSLog(@"Searching places for keywords: '%@'", keywords);
    [self performSearchForKeywords:keywords
                               url:[self placesUrl]
                   responseHandler:handler];
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
                                      requestMethod:requestMethod];

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

         handler(response, processedData, error);

         [req release];
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
    return [[self baseUrl] URLByAppendingPathComponent:@"api/events"];
}

- (NSURL *)trendUrl
{
    return [[self baseUrl] URLByAppendingPathComponent:@"api/events/trend"];
}

- (NSURL *)untrendUrl
{
    return [[self baseUrl] URLByAppendingPathComponent:@"api/events/untrend"];
}

- (NSURL *)placesUrl
{
    return [[self baseUrl] URLByAppendingPathComponent:@"api/places"];
}

@end



#import "LokaliteAccount.h"
#import "LokaliteAccount+KeychainAdditions.h"
#import "NSManagedObject+GeneralHelpers.h"
#import "UIApplication+GeneralHelpers.h"

#import <CoreData/CoreData.h>

@implementation LokaliteService (InstantiationHelpers)

+ (id)lokaliteServiceAuthenticatedIfPossible:(BOOL)authenticatedIfPossible
                                   inContext:(NSManagedObjectContext *)context
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    LokaliteService *service =
        [[LokaliteService alloc] initWithBaseUrl:baseUrl];

    if (authenticatedIfPossible) {
        LokaliteAccount *account = [LokaliteAccount findFirstInContext:context];
        if (account)
            [service setEmail:[account email] password:[account password]];
    }

    return [service autorelease];
}

@end
