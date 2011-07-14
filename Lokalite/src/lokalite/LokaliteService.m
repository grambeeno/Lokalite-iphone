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
#import "Event+MockDataHelpers.h"

#import "LokaliteDataParser.h"

#import "SDKAdditions.h"

@interface LokaliteService ()
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

#pragma mark - Events

- (void)fetchFeaturedEventsWithResponseHandler:(LSResponseHandler)handler
{
    NSLog(@"%@", NSStringFromSelector(_cmd));
    NSURL *url =
        [[self baseUrl] URLByAppendingPathComponent:@"api/events/browse"];
    LokaliteServiceRequest *req =
        [[LokaliteServiceRequest alloc] initWithUrl:url
                                         parameters:[NSDictionary dictionary]
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

- (id)processJsonData:(NSData *)data error:(NSError **)error
{
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

    return [LokaliteDataParser parseLokaliteData:data error:error];
}

@end
