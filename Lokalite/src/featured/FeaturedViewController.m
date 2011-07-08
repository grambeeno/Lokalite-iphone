//
//  FirstViewController.m
//  Lokalite
//
//  Created by John Debay on 7/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "FeaturedViewController.h"

@implementation FeaturedViewController

#pragma mark - UI events

- (void)toggleMapView:(id)sender
{
}

#pragma mark - UIViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIImage *mapImage = [UIImage imageNamed:@"radar"];
    UIBarButtonItem *mapButtonItem =
        [[UIBarButtonItem alloc] initWithImage:mapImage
                                         style:UIBarButtonItemStyleBordered
                                        target:self
                                        action:@selector(toggleMapView:)];
    [[self navigationItem] setRightBarButtonItem:mapButtonItem];
    [mapButtonItem release], mapButtonItem = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)io
{
    return io == UIInterfaceOrientationPortrait;
}

@end
