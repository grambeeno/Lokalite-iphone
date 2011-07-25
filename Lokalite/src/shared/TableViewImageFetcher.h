//
//  TableViewImageFetcher.h
//  Lokalite
//
//  Created by John Debay on 7/25/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^TVIFDataReceivedHandler)(NSData *data);
typedef void(^TVIFTableViewCellHandler)(UITableViewCell *cell,
                                        NSIndexPath *path);
typedef void(^TVIFErrorHandler)(NSError *error);

@interface TableViewImageFetcher : NSObject

#pragma mark - Fetching images

- (BOOL)fetchImageDataAtUrl:(NSURL *)url
                  tableView:(UITableView *)tableView
        dataReceivedHandler:(TVIFDataReceivedHandler)dataHandler
       tableViewCellHandler:(TVIFTableViewCellHandler)cellHandler
               errorHandler:(TVIFErrorHandler)errorHandler;

@end
