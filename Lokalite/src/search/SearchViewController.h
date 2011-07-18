//
//  SearchViewController.h
//  Lokalite
//
//  Created by John Debay on 7/18/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SearchViewController : UITableViewController

@property (nonatomic, retain)
    IBOutlet UISearchDisplayController *searchDisplayController;
@property (nonatomic, retain) UISearchBar *searchBar;

@end
