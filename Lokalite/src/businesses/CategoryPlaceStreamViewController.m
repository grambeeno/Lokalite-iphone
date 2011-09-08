//
//  CategoryPlaceStreamViewController.m
//  Lokalite
//
//  Created by John Debay on 8/11/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "CategoryPlaceStreamViewController.h"

#import "LokaliteStream.h"
#import "SearchLokaliteStream.h"

@implementation CategoryPlaceStreamViewController

@synthesize categoryName = categoryName_;
@synthesize categoryShortName = categoryShortName_;
@synthesize providedLokaliteStream = providedLokaliteStream_;

#pragma mark - Memory management

- (void)dealloc
{
    [categoryName_ release];
    [categoryShortName_ release];
    [providedLokaliteStream_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithCategoryName:(NSString *)categoryName
                 shortName:(NSString *)categoryShortName
            lokaliteStream:(LokaliteStream *)stream
                   context:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:@"CategoryPlaceStreamView" bundle:nil];
    if (self) {
        categoryName_ = [categoryName copy];
        categoryShortName_ = [categoryShortName copy];
        providedLokaliteStream_ = [stream retain];
        [self setContext:context];
    }

    return self;
}

#pragma mark - UIViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [[self navigationItem] setRightBarButtonItem:[self mapViewButtonItem]];

    UIBarButtonItem *backButton =
        [[UIBarButtonItem alloc] initWithTitle:[self categoryShortName]
                                         style:UIBarButtonItemStyleBordered
                                        target:nil
                                        action:nil];
    [[self navigationItem] setBackBarButtonItem:backButton];
    [backButton release], backButton = nil;

    [self setCanSearchServer:YES];
}

#pragma mark - PlaceStreamViewController implementation

- (NSString *)titleForView
{
    return [self categoryName];
}

- (LokaliteStream *)lokaliteStreamInstance
{
    return [self providedLokaliteStream];
}

#pragma mark Search - remote

#pragma mark Search - remote

- (NSString *)placeholderTextForRemoteSearchBar
{
    NSString *format =
        NSLocalizedString(@"search.places.category.placeholder.format", nil);
    return [NSString stringWithFormat:format, [self categoryName]];
}

- (NSString *)titleForRemoteSearchFooterView
{
    NSString *format =
        NSLocalizedString(@"search.places.category.title.format", nil);
    return [NSString stringWithFormat:format, [self categoryShortName]];
}

- (LokaliteStream *)remoteSearchLokaliteStreamInstanceForKeywords:
    (NSString *)keywords
{
    NSString *category = [self categoryName];
    return [SearchLokaliteStream placesSearchStreamWithKeywords:keywords
                                                       category:category
                                                        context:[self context]];
}

@end
