//
//  StaticEventListViewController.m
//  Lokalite
//
//  Created by John Debay on 9/2/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "StaticEventListViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "EventTableViewCell.h"
#import "EventDetailsViewController.h"

#import "SDKAdditions.h"

@implementation StaticEventListViewController

@synthesize events = events_;

#pragma mark - Initialization

- (id)initWithEvents:(NSArray *)events
{
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        events_ = [events copy];
        [self setTitle:NSLocalizedString(@"global.events", nil)];
    }

    return self;
}

#pragma mark - UITableviewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self tableView] setBackgroundColor:[UIColor tableViewBackgroundColor]];
    [[self tableView] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    [[self tableView] setRowHeight:[EventTableViewCell cellHeight]];
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return [[self events] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *reuseIdentifier = [EventTableViewCell defaultReuseIdentifier];
    EventTableViewCell *cell = (EventTableViewCell *)
        [tableView dequeueReusableCellWithIdentifier:reuseIdentifier];
    if (!cell)
        cell = [EventTableViewCell instanceFromNib];

    [cell configureCellForEvent:[[self events] objectAtIndex:[indexPath row]]
                displayDistance:YES];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [[self events] objectAtIndex:[indexPath row]];
    EventDetailsViewController *controller =
        [[EventDetailsViewController alloc] initWithEvent:event];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

@end
