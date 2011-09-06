//
//  PlaceEventLokaliteStream.m
//  Lokalite
//
//  Created by John Debay on 8/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlaceEventLokaliteStream.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "LokaliteService.h"

@implementation PlaceEventLokaliteStream

@synthesize place = place_;

#pragma mark - Memory management

- (void)dealloc
{
    [place_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithPlace:(Business *)place
     downloadSource:(LokaliteDownloadSource *)downloadSource
            baseUrl:(NSURL *)baseUrl
            context:(NSManagedObjectContext *)context
{
    self = [super initWithBaseUrl:baseUrl
                   downloadSource:downloadSource
                          context:context];
    if (self)
        place_ = [place retain];

    return self;
}

#pragma mark - LokaliteStream implementation

- (void)fetchNextBatchOfObjectsFromPage:(NSInteger)page
                        responseHandler:(LKSResponseHandler)handler
{
    LokaliteService *service = [self service];
    [service fetchEventsForPlaceId:[[self place] identifier]
                          fromPage:page
                   responseHandler:
     ^(NSHTTPURLResponse *response, NSDictionary *jsonObjects, NSError *error) {
         NSArray *parsedObjects = nil;
         if (jsonObjects) {
             parsedObjects =
                [Event eventObjectsFromJsonObjects:jsonObjects
                                    downloadSource:[self downloadSource]
                                       withContext:[self context]];

             CLLocationCoordinate2D coord = [self location];
             CLLocation *location = nil;
             if (CLLocationCoordinate2DIsValid(coord))
                 location =
                    [[[CLLocation alloc] initWithLatitude:coord.latitude
                                                longitude:coord.longitude]
                     autorelease];
             SEL selector = @selector(updateWithDistanceFromLocation:);
             [parsedObjects makeObjectsPerformSelector:selector
                                            withObject:location];
         }

         handler(parsedObjects, error);
     }];
}

@end


#import "UIApplication+GeneralHelpers.h"
#import "LokaliteDownloadSource.h"
#import "LokaliteDownloadSource+GeneralHelpers.h"

@implementation PlaceEventLokaliteStream (InstantiationHelpers)

+ (id)streamWithPlace:(Business *)place context:(NSManagedObjectContext *)moc
{
    NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
    NSString *sourceName =
        [NSString stringWithFormat:@"events?organization_id=%@", [place name]];
    LokaliteDownloadSource *source =
        [LokaliteDownloadSource downloadSourceWithName:sourceName
                                             inContext:moc
                                     createIfNecessary:YES];

    return [[[self alloc] initWithPlace:place
                         downloadSource:source
                                baseUrl:baseUrl
                                context:moc] autorelease];
}

@end
