//
//  LokaliteServiceRequest.m
//  Lokalite
//
//  Created by John Debay on 7/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteServiceRequest.h"
#import "SDKAdditions.h"

@interface LokaliteServiceRequest ()
@property (nonatomic, copy) LKRequestHandler requestHandler;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSHTTPURLResponse *response;

#pragma mark - Connection management

- (void)processConnectionStarted:(NSURLConnection *)connection;
- (void)processConnectionFinished;
@end

@implementation LokaliteServiceRequest

@synthesize url = url_;
@synthesize parameters = parameters_;
@synthesize requestMethod = requestMethod_;

@synthesize requestHandler = requestHandler_;

@synthesize connection = connection_;
@synthesize data = data_;
@synthesize response = response_;

#pragma mark - Memory management

- (void)dealloc
{
    [url_ release];
    [parameters_ release];

    [requestHandler_ release];

    [connection_ release];
    [data_ release];
    [response_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithUrl:(NSURL *)url
       parameters:(NSDictionary *)params
    requestMethod:(LKRequestMethod)requestMethod
{
    self = [super init];
    if (self) {
        url_ = [url copy];
        parameters_ = [params copy];
        requestMethod_ = requestMethod;
    }

    return self;
}

#pragma mark - Performing the request

- (void)performRequestWithHandler:(LKRequestHandler)handler
{
    [self setRequestHandler:handler];

    NSURL *url = [[self url] URLByAppendingGetParameters:[self parameters]];
    NSLog(@"Fetching data at URL: '%@'", url);
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection =
     [NSURLConnection connectionWithRequest:req delegate:self];
    [self processConnectionStarted:connection];
}

- (void)cancel
{
    [[self connection] cancel];
}

#pragma mark NSURLConnectionDelegate implementation

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [self setResponse:(NSHTTPURLResponse *) response];
    [self setData:[NSMutableData data]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [[self data] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self requestHandler]([self data], [self response], nil);
    [self processConnectionFinished];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self requestHandler](nil, [self response], error);
    [self processConnectionFinished];
}

#pragma mark - Connection management

- (void)processConnectionStarted:(NSURLConnection *)connection
{
    [self setConnection:connection];
    [[UIApplication sharedApplication] networkActivityIsStarting];
}

- (void)processConnectionFinished
{
    [self setConnection:nil];
    [[UIApplication sharedApplication] networkActivityDidFinish];
}

@end

