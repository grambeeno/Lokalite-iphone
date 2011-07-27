//
//  FeaturedEventsViewController.m
//  Lokalite
//
//  Created by John Debay on 7/27/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "FeaturedEventsViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"

#import "LokaliteFeaturedEventStream.h"

#import "LokaliteObjectBuilder.h"
#import "TableViewImageFetcher.h"

#import "SDKAdditions.h"

@interface FeaturedEventsViewController ()
@property (nonatomic, retain) TableViewImageFetcher *imageFetcher;
@end


@implementation FeaturedEventsViewController

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
    return NSLocalizedString(@"global.featured", nil);
}


#pragma mark - Configuring the table view

- (CGFloat)cellHeightForTableView:(UITableView *)tableView
{
    return [EventTableViewCell cellHeight];
}

- (NSString *)reuseIdentifierForIndexPath:(NSIndexPath *)indexPath
                              inTableView:(UITableView *)tableView
{
    return [EventTableViewCell defaultReuseIdentifier];
}

- (UITableViewCell *)tableViewCellInstanceForTableView:(UITableView *)tableView
                                       reuseIdentifier:(NSString *)identifier
{
    return [EventTableViewCell instanceFromNib];
}

- (void)configureCell:(EventTableViewCell *)cell forObject:(Event *)event
{
    [cell configureCellForEvent:event];

    UIImage *image = [event image];
    if (!image) {
        NSURL *url = [event fullImageUrl];

        [[self imageFetcher] fetchImageDataAtUrl:url
                                       tableView:[self tableView]
                             dataReceivedHandler:
         ^(NSData *data) {
             [event setImageData:data];
         }
                            tableViewCellHandler:
         ^(UIImage *image, UITableViewCell *tvc, NSIndexPath *path) {
             EventTableViewCell *cell = (EventTableViewCell *) tvc;
             if ([[cell eventId] isEqualToNumber:[event identifier]])
                 [[cell eventImageView] setImage:image];
         }
                                    errorHandler:
         ^(NSError *error) {
             NSLog(@"WARNING: Failed to fetch place image at: %@: %@", url,
                   error);
         }];
    }

    [[cell eventImageView] setImage:image];
}

- (void)displayDetailsForObject:(Event *)event
{
    EventDetailsViewController *controller =
        [[EventDetailsViewController alloc] initWithEvent:event];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

#pragma mark Working with the local data store

- (NSString *)lokaliteObjectEntityName
{
    return @"Event";
}

- (NSPredicate *)dataControllerPredicate
{
    return [NSPredicate predicateWithFormat:@"featured == YES"];
}

- (NSArray *)dataControllerSortDescriptors
{
    NSSortDescriptor *sd1 = [NSSortDescriptor sortDescriptorWithKey:@"endDate"
                                                          ascending:YES];
    NSSortDescriptor *sd2 = [NSSortDescriptor sortDescriptorWithKey:@"name"
                                                          ascending:YES];

    return [NSArray arrayWithObjects:sd1, sd2, nil];
}

#pragma mark Fetching data from the network

- (void)processNextBatchOfFetchedObjects:(NSArray *)events
                              pageNumber:(NSInteger)pageNumber
{
    if (pageNumber == 1) {
        NSManagedObjectContext *context = [self context];

        NSPredicate *pred = [self dataControllerPredicate];
        NSArray *allEvents = [Event findAllWithPredicate:pred
                                               inContext:context];

        [LokaliteObjectBuilder replaceLokaliteObjects:allEvents
                                          withObjects:events
                                      usingValueOfKey:@"identifier"
                                     remainingHandler:
         ^(Event *event) {
             NSLog(@"Deleting event: %@: %@", [event identifier], [event name]);
             if ([[event featured] boolValue])
                 [context deleteObject:event];
         }];
    }
}

- (LokaliteStream *)lokaliteStreamInstance
{
    return [LokaliteFeaturedEventStream streamWithContext:[self context]];
}

#pragma mark - Account events

- (BOOL)shouldResetDataForAccountAddition:(LokaliteAccount *)account
{
    return YES;
}

- (BOOL)shouldResetDataForAccountDeletion:(LokaliteAccount *)account
{
    return YES;
}

#pragma mark - Accessors

- (TableViewImageFetcher *)imageFetcher
{
    if (!imageFetcher_)
        imageFetcher_ = [[TableViewImageFetcher alloc] init];

    return imageFetcher_;
}

@end
