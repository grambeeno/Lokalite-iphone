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

#pragma mark - Looking up requests

@property (nonatomic, retain) NSMutableDictionary *requests;

#pragma mark - Sending requests

- (void)sendRequestWithUrl:(NSURL *)url
                parameters:(NSDictionary *)parameters
             requestMethod:(LKRequestMethod)requestMethod
           responseHandler:(LSResponseHandler)handler;

#pragma mark - Parameter helpers

- (NSMutableDictionary *)queryParametersForPage:(NSInteger)page;

#pragma mark - Request keys

- (NSValue *)keyForRequest:(LokaliteServiceRequest *)request;
- (LokaliteServiceRequest *)requestForKey:(NSValue *)value;

#pragma mark - Processing JSON data

- (id)processJsonData:(NSData *)data error:(NSError **)error;

@end

@implementation LokaliteService

@synthesize baseUrl = baseUrl_;

@synthesize location = location_;
@synthesize numberOfDaysBefore = numberOfDaysBefore_;
@synthesize orderBy = orderBy_;
@synthesize objectsPerPage = objectsPerPage_;

@synthesize email = email_;
@synthesize password = password_;

@synthesize requests = requests_;

#pragma mark - Memory management

- (void)dealloc
{
    NSLog(@"%@: %@", NSStringFromClass([self class]), NSStringFromSelector(_cmd));

    [baseUrl_ release];

    [numberOfDaysBefore_ release];
    [orderBy_ release];

    [email_ release];
    [password_ release];

    [requests_ release];
    
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url
{
    self = [super init];
    if (self) {
        baseUrl_ = [url copy];

        // reasonable defaults
        location_ = CLLocationCoordinate2DMake(FLT_MAX, FLT_MAX);
        orderBy_ = nil;  // default ordering; just to be explicit about it
        objectsPerPage_ = 10;

        requests_ = [[NSMutableDictionary alloc] init];
    }

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

#pragma mark - Cancelling requests

- (void)cancelAllRequests
{
    if ([[self requests] count]) {
        NSArray *keys = [[self requests] allKeys];
        for (NSValue *key in keys) {
            LokaliteServiceRequest *req = [self requestForKey:key];
            [req cancel];
            [req release];
        }
        [[self requests] removeAllObjects];
    }
}

#pragma mark - Events

- (void)fetchEventsWithCategory:(NSString *)category
                       fromPage:(NSInteger)page
                responseHandler:(LSResponseHandler)handler
{
    NSURL *url = [self featuredEventUrl];

    NSMutableDictionary *params = [self queryParametersForPage:page];
    if (category)
        [params setObject:category forKey:@"category"];

    [self sendRequestWithUrl:url
                  parameters:params
               requestMethod:LKRequestMethodGET
             responseHandler:handler];
}

- (void)fetchEventsForPlaceId:(NSNumber *)placeId
                     fromPage:(NSInteger)page
              responseHandler:(LSResponseHandler)handler
{
    NSURL *url = [self featuredEventUrl];

    NSMutableDictionary *params = [self queryParametersForPage:page];
    [params setObject:[placeId description] forKey:@"organization_id"];

    [self sendRequestWithUrl:url
                  parameters:params
               requestMethod:LKRequestMethodGET
             responseHandler:handler];
}

#pragma mark - Trending events

- (void)trendEventWithEventId:(NSNumber *)eventId
              anonymousUserId:(NSString *)anonymouseUserId
              responseHandler:(LSResponseHandler)handler
{
    NSURL *url = [self trendUrl];
    NSDictionary *params =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [eventId description], @"event_id",
         anonymouseUserId, @"uid", nil];

    [self sendRequestWithUrl:url
                  parameters:params
               requestMethod:LKRequestMethodPOST
             responseHandler:handler];
}

- (void)untrendEventWithEventId:(NSNumber *)eventId
                anonymousUserId:(NSString *)anonymouseUserId
                responseHandler:(LSResponseHandler)handler
{
    NSURL *url = [self untrendUrl];
    NSDictionary *params =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [eventId description], @"event_id",
         anonymouseUserId, @"uid", nil];

    [self sendRequestWithUrl:url
                  parameters:params
               requestMethod:LKRequestMethodPOST
             responseHandler:handler];
}

#pragma mark - Places

- (void)fetchPlacesWithCategory:(NSString *)category
                       fromPage:(NSInteger)page
                responseHandler:(LSResponseHandler)handler
{
    NSMutableDictionary *params = [self queryParametersForPage:page];
    if (category)
        [params setObject:category forKey:@"category"];

    [self sendRequestWithUrl:[self placesUrl]
                  parameters:params
               requestMethod:LKRequestMethodGET
             responseHandler:handler];
}

#pragma mark - Search

- (void)performSearchForKeywords:(NSString *)keywords
                        category:(NSString *)category
                             url:(NSURL *)url
                 responseHandler:(LSResponseHandler)handler
{
    NSString *encodedKeywords =
        [keywords
         stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSMutableDictionary *parameters =
        [NSMutableDictionary dictionaryWithObject:encodedKeywords
                                           forKey:@"keywords"];
    if (category)
        [parameters setObject:category forKey:@"category"];

    /*
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
     */

    [self sendRequestWithUrl:url
                  parameters:parameters
               requestMethod:LKRequestMethodGET
             responseHandler:handler];
}

- (void)searchEventsForKeywords:(NSString *)keywords
                       category:(NSString *)category
                responseHandler:(LSResponseHandler)handler
{
    NSLog(@"Searching events for keywords: '%@'", keywords);
    [self performSearchForKeywords:keywords
                          category:category
                               url:[self featuredEventUrl]
                   responseHandler:handler];
}

- (void)searchPlacesForKeywords:(NSString *)keywords
                       category:(NSString *)category
                responseHandler:(LSResponseHandler)handler
{
    NSLog(@"Searching places for keywords: '%@'", keywords);
    [self performSearchForKeywords:keywords
                          category:category
                               url:[self placesUrl]
                   responseHandler:handler];
}

#pragma mark - Sending requests

- (void)sendRequestWithUrl:(NSURL *)url
                parameters:(NSDictionary *)parameters
             requestMethod:(LKRequestMethod)requestMethod
           responseHandler:(LSResponseHandler)handler
{
    LokaliteServiceRequest *request =
        [[LokaliteServiceRequest alloc] initWithUrl:url
                                          parameters:parameters
                                       requestMethod:requestMethod];

    NSString *email = [self email], *password = [self password];
    if (email && password)
        [request authenticateWithUsername:email password:password];

    NSValue *requestKey = [self keyForRequest:request];
    NSMutableDictionary *requests = [self requests];

    LKRequestHandler requestHandler =
        ^(NSData *data, NSHTTPURLResponse *response, NSError *error) {
            id processedData = nil;
            if ([response statusCode] == 200) {
                if (data) {
                    NSError *error = nil;
                    processedData =
                        [LokaliteDataParser parseLokaliteData:data
                                                        error:&error];
                }
            }

            handler(response, processedData, error);

            [requests removeObjectForKey:requestKey];
            [request release];
        };

    [requests setObject:[[requestHandler copy] autorelease] forKey:requestKey];

    [request performRequestWithHandler:requestHandler];
}

#pragma mark - Parameter helpers

- (NSMutableDictionary *)queryParametersForPage:(NSInteger)page
{
    NSMutableDictionary *params =
        [NSMutableDictionary
         dictionaryWithObjectsAndKeys:
         [NSString stringWithFormat:@"%d", page], @"page",
         [NSString stringWithFormat:@"%d", [self objectsPerPage]], @"per_page",
         nil];

    if ([self orderBy]) {
        [params setObject:[self orderBy] forKey:@"order"];

        // HACK: only set the origin if we're ordering by distance
        BOOL orderByDistance = [[self orderBy] isEqualToString:@"distance"];
        CLLocationCoordinate2D coord = [self location];
        if (orderByDistance && CLLocationCoordinate2DIsValid(coord)) {
            NSString *origin =
                [NSString stringWithFormat:@"%f,%f",
                 coord.latitude, coord.longitude];
            [params setObject:origin forKey:@"origin"];

            if ([self numberOfDaysBefore]) {
                NSInteger ndays = [[self numberOfDaysBefore] integerValue];
                NSDate *before =
                    [[NSDate date] dateByAddingTimeInterval:
                     60 * 60 * 24 * ndays];
                NSString *beforeString = [before toLokaliteServerString];
                [params setObject:beforeString forKey:@"before"];
            }
        }
    }

    return params;
}

#pragma mark - Processing response data

- (id)processJsonData:(NSData *)data error:(NSError **)error
{
    return [LokaliteDataParser parseLokaliteData:data error:error];
}

#pragma mark - Request keys

- (NSValue *)keyForRequest:(LokaliteServiceRequest *)request
{
    return [NSValue valueWithNonretainedObject:request];
}

- (LokaliteServiceRequest *)requestForKey:(NSValue *)value
{
    return [value nonretainedObjectValue];
}

#pragma mark - URLs

- (NSURL *)profileUrl
{
    return [[self baseUrl] URLByAppendingPathComponent:@"api/1/profile"];
}

- (NSURL *)featuredEventUrl
{
    return [[self baseUrl] URLByAppendingPathComponent:@"api/1/events"];
}

- (NSURL *)trendUrl
{
    return [[self baseUrl] URLByAppendingPathComponent:@"api/1/events/trend"];
}

- (NSURL *)untrendUrl
{
    return [[self baseUrl] URLByAppendingPathComponent:@"api/1/events/untrend"];
}

- (NSURL *)placesUrl
{
    return [[self baseUrl] URLByAppendingPathComponent:@"api/1/places"];
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
