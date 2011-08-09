//
//  Business+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Business.h"

@class LokaliteDownloadSource;

@interface Business (GeneralHelpers)

#pragma mark - Lifecycle

- (BOOL)deleteIfAppropriate;

#pragma mark - Creating and finding businesses

+ (id)createOrUpdateBusinessFromJsonData:(NSDictionary *)businessData
                          downloadSource:(LokaliteDownloadSource *)source
                               inContext:(NSManagedObjectContext *)context;

+ (NSArray *)businessObjectsFromJsonObjects:(NSDictionary *)jsonObjects
                             downloadSource:(LokaliteDownloadSource *)source
                                withContext:(NSManagedObjectContext *)context;

@end


@interface Business (ConvenienceMethods)

- (UIImage *)image;
- (NSURL *)fullImageUrl;

- (NSURL *)addressUrl;
- (NSURL *)phoneUrl;

@end
