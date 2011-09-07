//
//  SimpleEventsViewController.m
//  Lokalite
//
//  Created by John Debay on 8/9/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "CategoryEventStreamViewController.h"

#import "Event.h"
#import "Event+GeneralHelpers.h"

#import "LokaliteStream.h"
#import "SearchLokaliteStream.h"

@implementation CategoryEventStreamViewController

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
    self = [super initWithNibName:@"CategoryEventStreamView" bundle:nil];
    if (self) {
        categoryName_ = [categoryName copy];
        categoryShortName_ = [categoryShortName copy];
        providedLokaliteStream_ = [stream retain];
        [providedLokaliteStream_ setOrderBy:@"starts_at"];
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

#pragma mark - EventStreamViewController implementation

- (NSString *)titleForView
{
    return [self categoryName];
}

- (LokaliteStream *)lokaliteStreamInstance
{
    return [self providedLokaliteStream];
}

#pragma mark Search - remote

- (NSString *)titleForRemoteSearchFooterView
{
    NSString *format =
        NSLocalizedString(@"search.events.category.title.format", nil);
    return [NSString stringWithFormat:format, [self categoryShortName]];
}

- (NSPredicate *)predicateForQueryString:(NSString *)queryString
{
    return [Event predicateForSearchString:queryString
                             includeEvents:YES
                         includeBusinesses:YES];
}

- (LokaliteStream *)remoteSearchLokaliteStreamInstanceForKeywords:
    (NSString *)keywords
{
    NSString *category = [self categoryName];
    return [SearchLokaliteStream eventSearchStreamWithKeywords:keywords
                                                      category:category
                                                       context:[self context]];
}

@end
