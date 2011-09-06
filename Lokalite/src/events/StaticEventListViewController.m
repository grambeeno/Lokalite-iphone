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

@interface StaticEventListViewController ()

#pragma mark - Updating for event states

- (void)observeChangesForEvent:(Event *)event;
- (void)stopObservingChangesForEvent:(Event *)event;

@end


@implementation StaticEventListViewController

@synthesize events = events_;

#pragma mark - Memory management

- (void)dealloc
{
    [events_ enumerateObjectsUsingBlock:
     ^(Event *event, NSUInteger idx, BOOL *stop) {
         [self stopObservingChangesForEvent:event];
     }];

    [events_ release];

    [super dealloc];
}

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

    [[self events] enumerateObjectsUsingBlock:
     ^(Event *event, NSUInteger idx, BOOL *stop) {
        [self observeChangesForEvent:event];
     }];
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

#pragma mark - UITableViewDelegate implementation

- (void)tableView:(UITableView *)tableView
    didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    Event *event = [[self events] objectAtIndex:[indexPath row]];
    EventDetailsViewController *controller =
        [[EventDetailsViewController alloc] initWithEvent:event];
    [[self navigationController] pushViewController:controller animated:YES];
    [controller release], controller = nil;
}

#pragma mark - Updating for event states



- (void)observeChangesForEvent:(Event *)event
{
    [event addObserver:self
            forKeyPath:@"mediumImageData"
               options:NSKeyValueObservingOptionNew |
                       NSKeyValueObservingOptionOld
               context:NULL];

    [event addObserver:self
            forKeyPath:@"trended"
               options:NSKeyValueObservingOptionNew |
                       NSKeyValueObservingOptionOld
               context:NULL];
}

- (void)stopObservingChangesForEvent:(Event *)event
{
    [event removeObserver:self forKeyPath:@"mediumImageData"];
    [event removeObserver:self forKeyPath:@"trended"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    NSInteger idx = [[self events] indexOfObject:object];
    if (idx != NSNotFound) {
        NSIndexPath *path = [NSIndexPath indexPathForRow:idx inSection:0];
        NSArray *paths = [NSArray arrayWithObject:path];
        [[self tableView] reloadRowsAtIndexPaths:paths
                                withRowAnimation:UITableViewRowAnimationNone];
    }
}

@end
