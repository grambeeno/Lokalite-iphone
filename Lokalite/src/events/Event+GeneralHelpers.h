//
//  Event+GeneralHelpers.h
//  Lokalite
//
//  Created by John Debay on 7/12/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "Event.h"

@class LokaliteDownloadSource;

@interface Event (GeneralHelpers)

#pragma mark - Creating and finding events

+ (id)eventWithId:(NSNumber *)eventId inContext:(NSManagedObjectContext *)moc;

+ (NSArray *)eventObjectsFromJsonObjects:(NSDictionary *)jsonObjects
                          downloadSource:(LokaliteDownloadSource *)source
                             withContext:(NSManagedObjectContext *)context;

+ (NSArray *)createOrUpdateEventsFromJsonArray:(NSArray *)jsonObjects
                                downloadSource:(LokaliteDownloadSource *)source
                                     inContext:(NSManagedObjectContext *)context;

+ (id)createOrUpdateEventFromJsonData:(NSDictionary *)eventData
                       downloadSource:(LokaliteDownloadSource *)source
                            inContext:(NSManagedObjectContext *)context;

+ (NSArray *)replaceObjectsFromJsonObjects:(NSDictionary *)jsonObjects
                            downloadSource:(LokaliteDownloadSource *)source
                                 inContext:(NSManagedObjectContext *)context;

//
// Get the predicate for a search string
//

+ (NSPredicate *)predicateForSearchString:(NSString *)searchString
                            includeEvents:(BOOL)includeEvents
                        includeBusinesses:(BOOL)includeBusinesses;

@end


@class CLLocation;

@interface Event (ConvenienceMethods)

- (NSString *)dateStringDescription;

- (BOOL)isTrended;
- (BOOL)isFeatured;

- (NSData *)standardImageData;
- (void)setStandardImageData:(NSData *)data;
- (UIImage *)standardImage;
- (NSString *)standardImageUrl;

@end


@interface Event (GeoHelpers)

//
// Convenience method for obtaining a CLLocation instance.
//
- (CLLocation *)locationInstance;

- (void)updateWithDistanceFromLocation:(CLLocation *)location;

@end



@interface Event (ViewControllerHelpers)

+ (NSArray *)dateTableViewSortDescriptors;
+ (NSArray *)locationTableViewSortDescriptors;

@end
