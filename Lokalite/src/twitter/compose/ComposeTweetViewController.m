//
//  ComposeTweetViewController.m
//  Lokalite
//
//  Created by John Debay on 8/24/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "ComposeTweetViewController.h"

#import "TwitterAccount.h"

@interface ComposeTweetViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem;

#pragma mark - View customization

- (void)updateInterfaceForText:(NSString *)text;
- (void)updateCharacterCountForText:(NSString *)text;

@end


@implementation ComposeTweetViewController

@synthesize twitterAccount = twitterAccount_;
@synthesize shareableObject = shareableObject_;

@synthesize textView = textView_;
@synthesize characterCountButton = characterCountButton_;

@synthesize shouldSendHandler = shouldSendHandler_;
@synthesize didCancelHandler = didCancelHandler_;

#pragma mark - Memory management

- (void)dealloc
{
    [twitterAccount_ release];
    [shareableObject_ release];

    [textView_ release];
    [characterCountButton_ release];

    [shouldSendHandler_ release];
    [didCancelHandler_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithTwitterAccount:(TwitterAccount *)twitterAccount
             shareableObject:(id<ShareableObject>)shareableObject
{
    self = [super initWithNibName:@"ComposeTweetView" bundle:nil];
    if (self) {
        twitterAccount_ = [twitterAccount retain];
        shareableObject_ = [shareableObject retain];

        [self setTitle:NSLocalizedString(@"twitter.send-tweet", nil)];
    }

    return self;
}

#pragma mark - UI events

- (void)cancel:(id)sender
{
    if ([self didCancelHandler])
        [self didCancelHandler]();
}

- (void)send:(id)sender
{
    if ([self shouldSendHandler]) {
        NSString *text = [[self textView] text];
        [self shouldSendHandler](text);
    }
}

#pragma mark - UIViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];

    NSString *text = [[self shareableObject] twitterText];
    [[self textView] setText:text];
    [self updateInterfaceForText:text];

    [[self textView] becomeFirstResponder];
}

#pragma mark - View initialization

- (void)initializeNavigationItem
{
    UIBarButtonItem *cancelButton =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                              target:self
                              action:@selector(cancel:)];
    [[self navigationItem] setLeftBarButtonItem:cancelButton];
    [cancelButton release], cancelButton = nil;

    UIBarButtonItem *sendButton =
        [[UIBarButtonItem alloc]
         initWithTitle:NSLocalizedString(@"global.send", nil)
                 style:UIBarButtonItemStyleDone
                target:self
                action:@selector(send:)];
    [[self navigationItem] setRightBarButtonItem:sendButton];
    [sendButton release], sendButton = nil;
}

#pragma mark - View customization

- (void)updateInterfaceForText:(NSString *)text
{
    UIBarItem *sendButton = [[self navigationItem] rightBarButtonItem];
    [sendButton setEnabled:[text length] <= 140];

    [self updateCharacterCountForText:text];
}

- (void)updateCharacterCountForText:(NSString *)text
{
    NSString *s = [NSString stringWithFormat:@"%d", 140 - [text length]];
    [[self characterCountButton] setTitle:s];
}

@end
