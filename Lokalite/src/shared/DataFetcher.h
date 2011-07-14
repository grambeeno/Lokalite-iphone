//
//  ImageFetcher.h
//  Lokalite
//
//  Created by John Debay on 7/13/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^DFResponseHandler)(NSData *, NSError *);

@interface DataFetcher : NSObject

#pragma mark - Fetching data

- (void)fetchDataAtUrl:(NSURL *)url responseHandler:(DFResponseHandler)handler;
+ (void)fetchDataAtUrl:(NSURL *)url responseHandler:(DFResponseHandler)handler;

@end
