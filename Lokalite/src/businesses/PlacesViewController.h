//
//  PlacesViewController.h
//  Lokalite
//
//  Created by John Debay on 7/21/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PlaceStreamViewController.h"

@interface PlacesViewController : PlaceStreamViewController

@property (nonatomic, retain) IBOutlet UISegmentedControl *placeSelector;

#pragma mark - UI events

- (IBAction)placeSelectorValueChanged:(id)sender;

@end
