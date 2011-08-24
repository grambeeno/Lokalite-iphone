//
//  YHOAuthTwitterEngine.m
//
//  Created by Isaiah Carew on 24 June 2009.
//  Copyright 2009 YourHead Software.
//
//  Some code and concepts taken from examples provided by 
//  Matt Gemmell and Chris Kimpton
//  See ReadMe for further attributions, copyrights and license info.
//

#import "MGTwitterHTTPURLConnection.h"

#import "OAConsumer.h"
#import "OAMutableURLRequest.h"
#import "OADataFetcher.h"

#import "YHOAuthTwitterEngine.h"


#define kOAuthAccessTokenKey			@"kOAuthAccessTokenKey"
#define kOAuthAccessTokenSecret			@"kOAuthAccessTokenSecret"

#define kYHOAuthClientName				@"Lokalite"
#define kYHOAuthClientVersion			@"1.0"
#define kYHOAuthClientURL				@"http://www.lokalite.com/"
#define kYHOAuthClientToken				@"Lokalite"

//
// You will need to change these!
// These should be your Key and Secret that you obtain from the
// Twitter app registration page:
//
// http://twitter.com/oauth_clients/new
// 
// Your info should look like this, but different (these are not valid keys).
// #define kOAuthConsumerKey			@"WGMqSPuYgphhTXRTwp14XQ"
// #define kOAuthConsumerSecret			@"OwzIslOmftD9smtZZuqs345XRtmsPeRzdKKYZo5h0U"
//
//#define kOAuthConsumerKey               @"7CxmfSFCpBJg6dmbFGRjw"
//#define kOAuthConsumerSecret			@"62PodhK5pwwUFqOjlJfvpSZROzOgTOXbGgc6QzWhGvI"

#define kYHOAuthTwitterAuthorizeURL		@"http://twitter.com/oauth/authorize"
#define kYHOAuthTwitterAccessTokenURL	@"http://twitter.com/oauth/access_token"
#define kYHOAuthTwitterRequestTokenURL	@"http://twitter.com/oauth/request_token"



@interface YHOAuthTwitterEngine (private)

- (void)_requestURL:(NSString *)urlString token:(OAToken *)token onSuccess:(SEL)success onFail:(SEL)fail;
- (void)_fail:(OAServiceTicket *)ticket data:(NSData *)data;

- (void)_setRequestToken:(OAServiceTicket *)ticket withData:(NSData *)data;
- (void)_setAccessToken:(OAServiceTicket *)ticket withData:(NSData *)data;

- (NSString *)_usernameFromHTTPResponseBody:(NSString *)body;

// MGTwitterEngine impliments this
// include it here just so that we
// can use this private method
- (NSString *)_queryStringWithBase:(NSString *)base parameters:(NSDictionary *)params prefixed:(BOOL)prefixed;

@end



@implementation YHOAuthTwitterEngine

@synthesize requestToken =	_requestToken;
@synthesize accessToken =	_accessToken;
@synthesize consumer =	_consumer;
@synthesize fetcher = _fetcher;



#pragma mark Constructors
// --------------------------------------------------------------------------------

+ (YHOAuthTwitterEngine *)oAuthTwitterEngineWithConsumerKey:(NSString *)consumerKey
                                             consumerSecret:(NSString *)consumerSecret
                                                   delegate:(NSObject<MGTwitterEngineDelegate> *)aDelegate;
{
    return [[[YHOAuthTwitterEngine alloc] initOAuthWithConsumerKey:consumerKey
                                                    consumerSecret:consumerSecret
                                                          delegate:aDelegate]
            autorelease];
}


- (YHOAuthTwitterEngine *)initOAuthWithConsumerKey:(NSString *)consumerKey
                                    consumerSecret:(NSString *)consumerSecret
                                          delegate:(NSObject<MGTwitterEngineDelegate> *)aDelegate;
{
    if ((self = (YHOAuthTwitterEngine *)[super initWithDelegate:aDelegate])) {
		self.consumer = [[[OAConsumer alloc] initWithKey:consumerKey secret:consumerSecret] autorelease];
		[self setClientName:kYHOAuthClientName 
					 version:kYHOAuthClientVersion 
						 URL:kYHOAuthClientURL 
					   token:kYHOAuthClientToken];
	}
    return self;
}

#pragma mark OAuth
// --------------------------------------------------------------------------------


//
// This looks locally and on the keychain for an access tokean
//
/*
- (BOOL)isAuthorized;
{	
	// if we already have an access token with a complete key and secret
	// then we can assume we're good to go.
	if ((self.accessToken.key) && (self.accessToken.secret)) {
		return YES;
	}
		
	// otherwise we should check the users keychain to see if we stored it
	NSString *accessTokenString = [[YHKeychainController sharedKeychainController] passwordForUsername:_username];
	if ((accessTokenString) && (![accessTokenString isEqualToString:@""])) {
		self.accessToken = [[[OAToken alloc] initWithHTTPResponseBody:accessTokenString] autorelease];
		if ((self.accessToken.key) && (self.accessToken.secret)) {
			return YES;
		}
	}
	
	// no access token found.  create a new empty one
	self.accessToken = [[[OAToken alloc] initWithKey:nil secret:nil] autorelease];
	return NO;
}
 */


//
// This uses the request token to generate a authorization URL.  When
// the user visits this URL they'll be asked to authorize our app
//
- (NSURLRequest *)authorizeURL
{
	// we need a valid request token to generate the URL
	if (!((self.requestToken.key) && (self.requestToken.secret))) {
		return nil;
	}

	OAMutableURLRequest* urlReq = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:kYHOAuthTwitterAuthorizeURL] consumer:nil token:self.requestToken realm:nil signatureProvider:nil] autorelease];	
	[urlReq setParameters:[NSArray arrayWithObject:[[[OARequestParameter alloc] initWithName:@"oauth_token" value:self.requestToken.key] autorelease]]];	
	return urlReq;
}


//
// Ask twitter to send us a request token
// we'll use the request token to authorize our app
// and eventually swap it for an access token.
//
- (void)requestRequestToken
{
	[self _requestURL:kYHOAuthTwitterRequestTokenURL token:nil onSuccess:@selector(_setRequestToken:withData:) onFail:@selector(_failedToGetRequestToken:error:)];
}


//
// Ask twitter to send us an access token
// the access token is used in the same way a username/password
// is used.
//
- (void)requestAccessToken:(NSString *)pin
{
    NSString * url =
        [NSString stringWithFormat:@"%@?oauth_verifier=%@",
        kYHOAuthTwitterAccessTokenURL, pin];
    [self _requestURL:url token:self.requestToken onSuccess:@selector(_setAccessToken:withData:) onFail:@selector(_failedToGetAccessToken:error:)];
	//[self _requestURL:kYHOAuthTwitterAccessTokenURL token:self.requestToken onSuccess:@selector(_setAccessToken:withData:) onFail:@selector(_fail:data:)];
}


//
// Clear our access token and removing it from the keychain
//
- (void)clearAccessToken
{
	//[[YHKeychainController sharedKeychainController] setPassword:@"" forUserName:_username];
	self.accessToken = nil;
}


#pragma mark OAuth private
// --------------------------------------------------------------------------------


//
// this is a convienence function that creates a twitter request of a token
// it creates a URL request, builds a token fetcher from it, then launches the fetch
//
- (void)_requestURL:(NSString *)urlString token:(OAToken *)token onSuccess:(SEL)success onFail:(SEL)fail
{
    OAMutableURLRequest *request = [[[OAMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString] consumer:self.consumer token:token realm:nil signatureProvider:nil] autorelease];
	if (!request)
		return;
	
    [request setHTTPMethod:@"POST"];
    self.fetcher = [[[OADataFetcher alloc] init] autorelease];
    [self.fetcher fetchDataWithRequest:request delegate:self didFinishSelector:success didFailSelector:fail];
}

- (void)_failedToGetRequestToken:(OAServiceTicket *)ticket error:(NSError *)error
{
    NSLog(@"failed to get request token: '%@'", error);
    if ([_delegate respondsToSelector:@selector(failedToReceiveRequestToken:error:)])
        [_delegate performSelector:@selector(failedToReceiveRequestToken:error:) withObject:self withObject:error];
}

//
// if the fetch fails this is what will happen
// you'll want to add your own error handling here.
//
//- (void)_fail:(OAServiceTicket *)ticket data:(NSData *)data
- (void)_failedToGetAccessToken:(OAServiceTicket *)ticket error:(NSError *)error
{
    NSLog(@"failed to get access token: '%@'", error);
    if ([_delegate respondsToSelector:@selector(failedToReceiveAccessToken:error:)])
		[_delegate performSelector:@selector(failedToReceiveAccessToken:error:) withObject:self withObject:error];
}

//
// request token callback
// when twitter sends us a request token this callback will fire
// we can store the request token to be used later for generating
// the authentication URL
//
- (void)_setRequestToken:(OAServiceTicket *)ticket withData:(NSData *)data
{
	if ((!ticket.didSucceed) || (!data))
		return;
	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (!dataString)
		return;
	self.requestToken = [[[OAToken alloc] initWithHTTPResponseBody:dataString] autorelease];
	[dataString release];
	dataString = nil;
	
	if ([_delegate respondsToSelector:@selector(receivedRequestToken:)])
		[_delegate performSelector:@selector(receivedRequestToken:) withObject:self];	
}


//
// access token callback
// when twitter sends us an access token this callback will fire
// we store it in our ivar as well as writing it to the keychain
// 
- (void)_setAccessToken:(OAServiceTicket *)ticket withData:(NSData *)data
{
	if ((!ticket.didSucceed) || (!data))
		return;
	
	NSString *dataString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	if (!dataString)
		return;

	// we don't actually need to store the user name, but in a multi-account
	// app you'll need to give the user some indication about which account is currently
	// authenticated.
	// we don't need to store this back in the twitter engine.  but there's already an
	// ivar there, so let's not waste it.
	// the username is embedded in this access token respons but will not be parsed by the 
	// access token parser, so let's just do it here before moving on.
	NSString *username = [self _usernameFromHTTPResponseBody:dataString];
	if ((username) && (![username isEqualToString:@""])) {
		[self setUsername:username password:nil];
		//[[YHKeychainController sharedKeychainController] setPassword:dataString forUserName:username];
	}
	
	self.accessToken = [[[OAToken alloc] initWithHTTPResponseBody:dataString] autorelease];
	[dataString release];
	dataString = nil;

    if (self.accessToken.key == nil || self.accessToken.secret == nil) {
        NSString * localizedDescription = @"Failed to validate PIN.";
        NSMutableDictionary * userInfo = [NSMutableDictionary dictionaryWithCapacity:2];
        [userInfo setObject:localizedDescription forKey:NSLocalizedDescriptionKey];
        NSError * error = [NSError errorWithDomain:@"TwitterOauthErrorDomain"
                                              code:1
                                          userInfo:userInfo];
        [self _failedToGetAccessToken:ticket error:error];
	} else if ([_delegate respondsToSelector:@selector(receivedAccessToken:)])
		[_delegate performSelector:@selector(receivedAccessToken:) withObject:self];	
}


- (NSString *)_usernameFromHTTPResponseBody:(NSString *)body
{
	if (!body)
		return nil;
	
	NSArray *tuples = [body componentsSeparatedByString:@"&"];
	if ((!tuples) || (tuples.count < 1))
		return nil;
	
	for (NSString *tuple in tuples) {
		NSArray *keyValueArray = [tuple componentsSeparatedByString:@"="];
		if ((keyValueArray) && (keyValueArray.count == 2)) {
			NSString *key = [keyValueArray objectAtIndex:0];
			NSString *value = [keyValueArray objectAtIndex:1];
			if ([key isEqualToString:@"screen_name"]) {
				return value;
			}
		}
	}
	
	return nil;
}



#pragma mark MGTwitterEngine Changes
// --------------------------------------------------------------------------------
//
// these method overrides were created from the work that Chris Kimpton
// did.  i've chosen to subclass instead of directly modifying the
// MGTwitterEngine as it makes integrating MGTwitterEngine changes a bit
// easier.
// 
// the code here is largely unchanged from chris's implimentation.
// i've tried to highlight the areas that differ from 
// the base class implimentation.
//
// --------------------------------------------------------------------------------

#define SET_AUTHORIZATION_IN_HEADER 1

- (NSString *)_sendRequestWithMethod:(NSString *)method 
                                path:(NSString *)path 
                     queryParameters:(NSDictionary *)params 
                                body:(NSString *)body 
                         requestType:(MGTwitterRequestType)requestType 
                        responseType:(MGTwitterResponseType)responseType
{
    NSString *fullPath = path;

	if (params && ![method isEqualToString:@"POST"])
	    fullPath = [self _queryStringWithBase:fullPath parameters:params prefixed:YES];

    NSString * domain = nil, * connectionType = nil;
    NSString * version = nil;
    if (requestType == MGTwitterSearchRequest) {
		domain = _searchDomain;
        version = @"";
		connectionType = @"http";
	} else {
		domain = _APIDomain;
        version = [[self class] useVersionedApi] ? [NSString stringWithFormat:@"/%@", _APIVersion] : @"";
		if (_secureConnection)
			connectionType = @"https";
		else
			connectionType = @"http";
	}

    NSString *urlString = [NSString stringWithFormat:@"%@://%@%@/%@", connectionType, domain, version, fullPath];
    NSURL *finalURL = [NSURL URLWithString:urlString];
    if (!finalURL) {
        return nil;
    } else
        NSLog(@"Sending: %@", finalURL);
	
	// --------------------------------------------------------------------------------
	// modificaiton from the base clase
	// the base class creates a regular url request
	// we're going to create an oauth url request
	// --------------------------------------------------------------------------------
	//    NSMutableURLRequest *theRequest = [NSMutableURLRequest requestWithURL:finalURL 
	//                                                              cachePolicy:NSURLRequestReloadIgnoringCacheData 
	//                                                          timeoutInterval:URL_REQUEST_TIMEOUT];
	// --------------------------------------------------------------------------------
	
	OAMutableURLRequest *theRequest = [[[OAMutableURLRequest alloc] initWithURL:finalURL
																	   consumer:self.consumer token:self.accessToken realm:nil
															  signatureProvider:nil] autorelease];
    if (method) {
        [theRequest setHTTPMethod:method];
    }
    [theRequest setHTTPShouldHandleCookies:NO];
    
    // Set headers for client information, for tracking purposes at Twitter.
    /*
    [theRequest setValue:_clientName    forHTTPHeaderField:@"X-Twitter-Client"];
    [theRequest setValue:_clientVersion forHTTPHeaderField:@"X-Twitter-Client-Version"];
    [theRequest setValue:_clientURL     forHTTPHeaderField:@"X-Twitter-Client-URL"];
     */
    
    // Set the request body if this is a POST request.
    BOOL isPOST = (method && [method isEqualToString:@"POST"]);
    if (isPOST) {
        // Set request body, if specified (hopefully so), with 'source' parameter if appropriate.
        NSString *finalBody = @"";
		if (body) {
			finalBody = [finalBody stringByAppendingString:body];
		}
        if (_clientSourceToken) {
            finalBody = [finalBody stringByAppendingString:[NSString stringWithFormat:@"%@source=%@", 
                                                            (body) ? @"&" : @"?" , 
                                                            _clientSourceToken]];
        }
        
        if (finalBody) {
            [theRequest setHTTPBody:[finalBody dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }


	// --------------------------------------------------------------------------------
	// modificaiton from the base clase
	// our version "prepares" the oauth url request
	// --------------------------------------------------------------------------------
	[theRequest prepare];
    
    // Create a connection using this request, with the default timeout and caching policy, 
    // and appropriate Twitter request and response types for parsing and error reporting.
    MGTwitterHTTPURLConnection *connection;
    connection = [[MGTwitterHTTPURLConnection alloc] initWithRequest:theRequest 
                                                            delegate:self 
                                                         requestType:requestType 
                                                        responseType:responseType];
    
    if (!connection) {
        return nil;
    } else {
        [_connections setObject:connection forKey:[connection identifier]];
        [connection release];
    }
    
    return [connection identifier];
}


- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
	
	// --------------------------------------------------------------------------------
	// modificaiton from the base clase
	// instead of answering the authentication challenge, we just ignore it.
	// seems a bit odd to me, but this is what Chris Kimpton did and it seems to work,
	// so i'm rolling with it.
	// --------------------------------------------------------------------------------
	//	if ([challenge previousFailureCount] == 0 && ![challenge proposedCredential]) {
	//		NSURLCredential *credential = [NSURLCredential credentialWithUser:_username password:_password 
	//															  persistence:NSURLCredentialPersistenceForSession];
	//		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	//	} else {
	//		[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
	//	}
	// --------------------------------------------------------------------------------

	[[challenge sender] continueWithoutCredentialForAuthenticationChallenge:challenge];
	return;
	
}


//- (NSString *)sendUpdate:(NSString *)status inReplyTo:(int)updateID
//{
//    if (!status) {
//        return nil;
//    }
//    
//    NSString *path = @"statuses/update.xml";
//    
//    NSString *trimmedText = status;
//    if ([trimmedText length] > 140) {
//        trimmedText = [trimmedText substringToIndex:140];
//    }
//    
//    NSMutableDictionary *params = [NSMutableDictionary dictionaryWithCapacity:0];
//    [params setObject:trimmedText forKey:@"status"];
//    if (updateID > 0) {
//        [params setObject:[NSString stringWithFormat:@"%d", updateID] forKey:@"in_reply_to_status_id"];
//    }
//	//	[params addEntriesFromDictionary:self.oauthParams];
//    NSString *body = [self _queryStringWithBase:nil parameters:params prefixed:NO];
//    
//    return [self _sendRequestWithMethod:@"POST" path:path 
//                        queryParameters:params body:body 
//                            requestType:MGTwitterStatusSend 
//                           responseType:MGTwitterStatus];
//}


@end
