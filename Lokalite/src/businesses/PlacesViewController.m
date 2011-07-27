//
//  PlacesViewController.m
//  Lokalite
//
//  Created by John Debay on 7/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "PlacesViewController.h"

#import "LokaliteAccount.h"

#import "Business.h"
#import "Business+GeneralHelpers.h"
#import "BusinessDetailsViewController.h"

#import "PlaceTableViewCell.h"

#import "LokaliteStream.h"
#import "LokalitePlacesStream.h"

#import "TableViewImageFetcher.h"

#import "SDKAdditions.h"

@interface PlacesViewController ()

@property (nonatomic, retain) TableViewImageFetcher *imageFetcher;

@end


@implementation PlacesViewController

@synthesize imageFetcher = imageFetcher_;

#pragma mark - Memory management

- (void)dealloc
{
    [imageFetcher_ release];
    [super dealloc];
}

#pragma mark - LokaliteStreamViewController implementation

#pragma mark Configuring the view

- (NSString *)titleForView
{
    return NSLocalizedString(@"global.places", nil);
}

#pragma mark - Configuring the table view

- (CGFloat)cellHeightForTableView:(UITableView *)tableView
{
    return [PlaceTableViewCell cellHeight];
}

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView
{
    return [PlaceTableViewCell defaultReuseIdentifier];
}

- (UITableViewCell *)tableViewCellInstanceForTableView:(UITableView *)tableView
                                       reuseIdentifier:(NSString *)identifier
{
    return [PlaceTableViewCell instanceFromNib];
}

- (void)configureCell:(PlaceTableViewCell *)cell forObject:(Business *)place
{
    [cell configureCellForPlace:place];

    UIImage *image = [place image];
    if (image)
        [[cell placeImageView] setImage:image];
    else {
        NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
        NSString *urlPath = [place imageUrl];
        NSURL *url = [baseUrl URLByAppendingPathComponent:urlPath];

        [[self imageFetcher] fetchImageDataAtUrl:url
                                       tableView:[self tableView]
                             dataReceivedHandler:
         ^(NSData *data) {
             [place setImageData:data];
         }
                            tableViewCellHandler:
         ^(UIImage *image, UITableViewCell *tvc, NSIndexPath *path) {
             PlaceTableViewCell *cell = (PlaceTableViewCell *) tvc;
             if ([[cell placeId] isEqualToNumber:[place identifier]])
                 [[cell placeImageView] setImage:image];
         }
                                    errorHandler:
         ^(NSError *error) {
             NSLog(@"WARNING: Failed to fetch place image at: %@", url);
         }];
    }
}

- (void)displayDetailsForObject:(Business *)place
{
    BusinessDetailsViewController *controller =
        [[BusinessDetailsViewController alloc] initWithBusiness:place];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

#pragma mark Working with the local data store

- (NSString *)lokaliteObjectEntityName
{
    return @"Business";
}

- (NSArray *)dataControllerSortDescriptors
{
    NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                         ascending:YES];
    return [NSArray arrayWithObject:sd];
}

- (LokaliteStream *)lokaliteStreamInstance
{
    return [LokalitePlacesStream streamWithContext:[self context]];
}

#pragma mark - Account events

- (BOOL)shouldResetDataForAccountAddition:(LokaliteAccount *)account
{
    return NO;
}

#pragma mark - Accessors

- (TableViewImageFetcher *)imageFetcher
{
    if (!imageFetcher_)
        imageFetcher_ = [[TableViewImageFetcher alloc] init];

    return imageFetcher_;
}

@end
