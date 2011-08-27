//
//  ComposeTweetViewController.m
//  Lokalite
//
//  Created by John Debay on 8/24/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "ComposeTweetViewController.h"

#import "TwitterAccount.h"

#import "LokaliteAppDelegate.h"

@interface ComposeTweetViewController ()

@property (nonatomic, copy) NSString *tweetText;

#pragma mark - View initialization

- (void)initializeNavigationItem;

#pragma mark - View customization

- (void)updateInterfaceForText:(NSString *)text;
- (void)updateCharacterCountForText:(NSString *)text;

@end


@implementation ComposeTweetViewController

@synthesize twitterAccount = twitterAccount_;
@synthesize tweetText = tweetText_;

@synthesize textView = textView_;
@synthesize characterCountButton = characterCountButton_;

@synthesize shouldSendHandler = shouldSendHandler_;
@synthesize didCancelHandler = didCancelHandler_;

#pragma mark - Memory management

- (void)dealloc
{
    [twitterAccount_ release];
    [tweetText_ release];

    [textView_ release];
    [characterCountButton_ release];

    [shouldSendHandler_ release];
    [didCancelHandler_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithTwitterAccount:(TwitterAccount *)twitterAccount
                   tweetText:(NSString *)tweetText
{
    self = [super initWithNibName:@"ComposeTweetView" bundle:nil];
    if (self) {
        twitterAccount_ = [twitterAccount retain];
        tweetText_ = [tweetText copy];

        [self setTitle:NSLocalizedString(@"twitter.send-tweet", nil)];
    }

    return self;
}

#pragma mark - UI events

- (void)cancel:(id)sender
{
    NSString *cancelButtonTitle = NSLocalizedString(@"global.cancel", nil);
    NSString *destructiveButtonTitle =
        NSLocalizedString(@"twitter.compose-tweet.destroy-draft", nil);

    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:nil
                                    delegate:self
                           cancelButtonTitle:cancelButtonTitle
                      destructiveButtonTitle:destructiveButtonTitle
                           otherButtonTitles:nil];

    LokaliteAppDelegate *delegate = (LokaliteAppDelegate *)
        [[UIApplication sharedApplication] delegate];
    [sheet showFromTabBar:[[delegate tabBarController] tabBar]];
    [sheet release], sheet = nil;
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

    NSString *text = [self tweetText];
    [[self textView] setText:text];
    [self updateInterfaceForText:text];

    [[self textView] becomeFirstResponder];
}

#pragma mark - UITextViewDelegate implementation

- (void)textViewDidChange:(UITextView *)textView
{
    [self updateInterfaceForText:[textView text]];
}

#pragma mark - UIActionSheetDelegate implementation

- (void)actionSheet:(UIActionSheet *)actionSheet
    clickedButtonAtIndex:(NSInteger)buttonIndex
{
     if (buttonIndex == 0 && [self didCancelHandler])
        [self didCancelHandler]();
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
