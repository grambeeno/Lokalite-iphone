//
//  ImageFetcher.m
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "DataFetcher.h"

@interface NSValue (DataFetcherHelpers)
+ (id)valueForConnection:(NSURLConnection *)connection;
@end

@interface DataFetcher ()
@property (nonatomic, retain) NSMutableDictionary *connectionData;
@property (nonatomic, retain) NSMutableDictionary *connectionHandlers;

#pragma mark - Connection management

- (void)cleanupConnection:(NSURLConnection *)connection;
@end

@implementation DataFetcher

@synthesize connectionData = connectionData_;
@synthesize connectionHandlers = connectionHandlers_;

#pragma mark - Memory management

- (void)dealloc
{
    [connectionData_ release];
    [connectionHandlers_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self) {
        connectionData_ = [[NSMutableDictionary alloc] init];
        connectionHandlers_ = [[NSMutableDictionary alloc] init];
    }

    return self;
}

#pragma mark - Fetch data

- (void)fetchDataAtUrl:(NSURL *)url responseHandler:(DFResponseHandler)handler
{
    NSURLRequest *req = [NSURLRequest requestWithURL:url];
    NSURLConnection *connection =
        [NSURLConnection connectionWithRequest:req delegate:self];
    NSValue *value = [NSValue valueForConnection:connection];

    [[self connectionData] setObject:[NSMutableData data] forKey:value];
    [[self connectionHandlers] setObject:[handler copy] forKey:value];
}

+ (void)fetchDataAtUrl:(NSURL *)url responseHandler:(DFResponseHandler)handler
{
    static NSMutableDictionary *fetchers = nil;
    if (!fetchers)
        fetchers = [[NSMutableDictionary alloc] init];

    DataFetcher *fetcher = [[DataFetcher alloc] init];
    [fetcher fetchDataAtUrl:url responseHandler:^(NSData *data, NSError *error) {
        handler(data, error);
        [fetcher release];
    }];
}

#pragma mark - NSURLConnectionDelegate implementation

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    NSValue *key = [NSValue valueForConnection:connection];
    [[self connectionData] setObject:[NSMutableData data] forKey:key];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    NSValue *key = [NSValue valueForConnection:connection];
    [[[self connectionData] objectForKey:key] appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    NSValue *key = [NSValue valueForConnection:connection];
    DFResponseHandler handler = [[self connectionHandlers] objectForKey:key];
    NSData *data = [[self connectionData] objectForKey:key];

    handler(data, nil);

    [self cleanupConnection:connection];
}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    NSValue *key = [NSValue valueForConnection:connection];
    DFResponseHandler handler = [[self connectionHandlers] objectForKey:key];
    handler(nil, error);

    [self cleanupConnection:connection];
}

#pragma mark - Connection management

- (void)cleanupConnection:(NSURLConnection *)connection
{
    NSValue *key = [NSValue valueForConnection:connection];
    [[self connectionData] removeObjectForKey:key];
    [[self connectionHandlers] removeObjectForKey:key];
}

@end

@implementation NSValue (DataFetcherHelpers)

#pragma mark - Helpers

+ (id)valueForConnection:(NSURLConnection *)connection
{
    return [NSValue valueWithNonretainedObject:connection];
}

@end
