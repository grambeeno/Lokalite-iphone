//
//  LokaliteService.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef void(^LSResponseHandler)(NSHTTPURLResponse *,
                                 NSDictionary *,
                                 NSError *);

@interface LokaliteService : NSObject

@property (nonatomic, copy, readonly) NSURL *baseUrl;

@property (nonatomic, assign) CLLocationCoordinate2D location;
@property (nonatomic, retain) NSString *orderBy;
@property (nonatomic, assign) NSInteger objectsPerPage;

@property (nonatomic, copy, readonly) NSString *email;
@property (nonatomic, copy, readonly) NSString *password;

#pragma mark - Initialization

- (id)initWithBaseUrl:(NSURL *)url;

#pragma mark - Authentication

- (void)fetchProfileWithResponseHandler:(LSResponseHandler)handler;

- (void)setEmail:(NSString *)email password:(NSString *)password;
- (void)removeEmailAndPassword;

#pragma mark - Events

- (void)fetchEventsWithCategory:(NSString *)category
                       fromPage:(NSInteger)page
                responseHandler:(LSResponseHandler)handler;

#pragma mark - Trending events

- (void)trendEventWithEventId:(NSNumber *)eventId
              responseHandler:(LSResponseHandler)handler;
- (void)untrendEventWithEventId:(NSNumber *)eventId
                responseHandler:(LSResponseHandler)handler;

#pragma mark - Places

- (void)fetchPlacesWithCategory:(NSString *)category
                responseHandler:(LSResponseHandler)handler;

#pragma mark - Search

- (void)searchEventsForKeywords:(NSString *)keywords
                responseHandler:(LSResponseHandler)handler;
- (void)searchPlacesForKeywords:(NSString *)keywords
                responseHandler:(LSResponseHandler)handler;

#pragma mark - URLs

- (NSURL *)profileUrl;
- (NSURL *)featuredEventUrl;
- (NSURL *)trendUrl;
- (NSURL *)untrendUrl;
- (NSURL *)placesUrl;

@end



@class NSManagedObjectContext;

@interface LokaliteService (InstantiationHelpers)

+ (id)lokaliteServiceAuthenticatedIfPossible:(BOOL)authenticatedIfPossible
                                   inContext:(NSManagedObjectContext *)context;

@end
