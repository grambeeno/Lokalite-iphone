//
//  LocationViewController.m
//  Lokalite
//
//  Created by John Debay on 8/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LocationViewController.h"
#import "MappableLokaliteObject.h"
#import "MapDisplayController.h"
#import "LokaliteAppDelegate.h"

@interface LocationViewController ()
@property (nonatomic, retain) MapDisplayController *displayController;

- (MKMapView *)mapView;
@end


@implementation LocationViewController

@synthesize mappableObject = mappableObject_;
@synthesize displayController = diplayController_;

#pragma mark - Memory management

- (void)dealloc
{
    [mappableObject_ release];
    [diplayController_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithMappableLokaliteObject:(id<MappableLokaliteObject>)object
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        mappableObject_ = [object retain];
        [self setTitle:NSLocalizedString(@"global.location", nil)];
    }

    return self;
}

#pragma mark - UI events

- (void)actionButtonTapped:(id)sender
{
    NSString *title = nil;
    NSString *cancelButtonTitle = NSLocalizedString(@"global.cancel", nil);
    NSString *destructiveButtonTitle = nil;
    NSString *openInMapsButtonTitle =
        NSLocalizedString(@"global.open-in-maps", nil);
    NSString *directionsInMapsButtonTitle =
        NSLocalizedString(@"global.directions-in-maps", nil);

    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:title
                                    delegate:self
                           cancelButtonTitle:cancelButtonTitle
                      destructiveButtonTitle:destructiveButtonTitle
                           otherButtonTitles:openInMapsButtonTitle,
                                             directionsInMapsButtonTitle, nil];

    LokaliteAppDelegate *appDelegate =
        (LokaliteAppDelegate *) [[UIApplication sharedApplication] delegate];
    [sheet showFromTabBar:[[appDelegate tabBarController] tabBar]];
    [sheet release], sheet = nil;
}

#pragma mark - UIViewController implementation

- (void)loadView
{
    [super loadView];

    MKMapView *mapView = [[MKMapView alloc] initWithFrame:CGRectZero];
    [self setView:mapView];
    [mapView release], mapView = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    NSArray *annotations =
        [NSArray arrayWithObject:[[self mappableObject] mapAnnotation]];
    MapDisplayController *displayController =
        [[MapDisplayController alloc] initWithMapView:[self mapView]];
    [displayController setAnnotations:annotations];
    [displayController setAnnotationsShowRightAccessoryView:NO];

    UIBarButtonItem *actionItem =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                              target:self
                              action:@selector(actionButtonTapped:)];
    [[self navigationItem] setRightBarButtonItem:actionItem];
    [actionItem release], actionItem = nil;
}

#pragma mark - UIActionSheetDelegate implementation

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSURL *url = nil;
    if (buttonIndex == 0)
        // open in maps
        url = [[self mappableObject] addressUrl];
    else if (buttonIndex == 1) {
        // directions
        CLLocation *location =
            [[[[self displayController] mapView] userLocation] location];
        url = [[self mappableObject] directionsUrlFromLocation:location];
    }

    if (url)
        [[UIApplication sharedApplication] openURL:url];
}

#pragma mark - Accessors

- (MKMapView *)mapView
{
    return (MKMapView *) [self view];
}

@end
