//
//  TableViewImageFetcher.m
//  Lokalite
//
//  Created by John Debay on 7/25/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TableViewImageFetcher.h"

#import "DataFetcher.h"
#import "SDKAdditions.h"

@interface TableViewImageFetcher ()
@property (nonatomic, retain) NSMutableSet *pendingUrls;
@end


@implementation TableViewImageFetcher

@synthesize pendingUrls = pendingUrls_;

#pragma mark - Memory management

- (void)dealloc
{
    [pendingUrls_ release];
    [super dealloc];
}

#pragma mark - Initialization

- (id)init
{
    self = [super init];
    if (self)
        pendingUrls_ = [[NSMutableSet alloc] init];
    
    return self;
}

#pragma mark - Fetching images

- (BOOL)fetchImageDataAtUrl:(NSURL *)url
                  tableView:(UITableView *)tableView
        dataReceivedHandler:(TVIFDataReceivedHandler)dataHandler
       tableViewCellHandler:(TVIFTableViewCellHandler)cellHandler
               errorHandler:(TVIFErrorHandler)errorHandler
{
    BOOL needsFetching = ![[self pendingUrls] containsObject:url];

    if (needsFetching) {
        NSLog(@"Fetching image at URL: '%@'", url);

        [[UIApplication sharedApplication] networkActivityIsStarting];
        [[self pendingUrls] addObject:url];

        [DataFetcher fetchDataAtUrl:url responseHandler:
         ^(NSData *data, NSError *error) {
             [[UIApplication sharedApplication] networkActivityDidFinish];

             if (data) {
                 dataHandler(data);

                 NSArray *visibleCells = [tableView visibleCells];
                 [visibleCells enumerateObjectsUsingBlock:
                  ^(UITableViewCell *cell, NSUInteger idx, BOOL *stop) {
                      NSIndexPath *path = [tableView indexPathForCell:cell];
                      cellHandler(cell, path);
                  }];
             } else
                 errorHandler(error);

             [[self pendingUrls] removeObject:url];
         }];
    }

    return needsFetching;
}

@end
