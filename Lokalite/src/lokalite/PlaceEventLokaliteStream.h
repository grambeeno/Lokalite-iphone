//
//  PlaceEventLokaliteStream.h
//  Lokalite
//
//  Created by John Debay on 8/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteStream.h"

@class Business;

@interface PlaceEventLokaliteStream : LokaliteStream

@property (nonatomic, retain, readonly) Business *place;

#pragma mark - Initialization

- (id)initWithPlace:(Business *)place
     downloadSource:(LokaliteDownloadSource *)downloadSource
            baseUrl:(NSURL *)baseUrl
            context:(NSManagedObjectContext *)context;

@end


@interface PlaceEventLokaliteStream (InstantiationHelpers)

+ (id)streamWithPlace:(Business *)place context:(NSManagedObjectContext *)moc;

@end
