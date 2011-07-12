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

@property (nonatomic, retain) NSMutableData *data;
@property (nonatomic, retain) NSHTTPURLResponse *response;
@end

@implementation LokaliteServiceRequest

@synthesize url = url_;
@synthesize parameters = parameters_;
@synthesize requestMethod = requestMethod_;

@synthesize requestHandler = requestHandler_;

@synthesize data = data_;
@synthesize response = response_;

#pragma mark - Memory management

- (void)dealloc
{
    [url_ release];
    [parameters_ release];

    [requestHandler_ release];

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

- (void)performRequestWithHandler:(LKRequestHandler)handler
{
    [self setRequestHandler:handler];

    NSURL *url = [[self url] URLByAppendingGetParameters:[self parameters]];
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    [NSURLConnection connectionWithRequest:req delegate:self];
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
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    [self requestHandler](nil, [self response], error);
}

@end

