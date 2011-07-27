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

             // HACK: if the image is not found, we get a 404 HTML page that
             // UIImage correctly can not create an image from. Check for that
             // case specifically.
             UIImage *image = [UIImage imageWithData:data];
             if (data && image) {
                 dataHandler(data);

                 NSArray *visibleCells = [tableView visibleCells];
                 [visibleCells enumerateObjectsUsingBlock:
                  ^(UITableViewCell *cell, NSUInteger idx, BOOL *stop) {
                      NSIndexPath *path = [tableView indexPathForCell:cell];
                      cellHandler(image, cell, path);
                  }];
             } else {
                 if (!error)
                     // HACK: see note above
                     error = [NSError errorForHTTPStatusCode:404];

                 errorHandler(error);
             }

             [[self pendingUrls] removeObject:url];
         }];
    }

    return needsFetching;
}

@end
