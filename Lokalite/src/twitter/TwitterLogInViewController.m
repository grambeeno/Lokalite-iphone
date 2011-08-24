//
//  TwitterLogInViewController.m
//  Lokalite
//
//  Created by John Debay on 8/23/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "TwitterLogInViewController.h"

#import "LokaliteTwitterOAuthSettings.h"

@interface TwitterLogInViewController ()

#pragma mark - View initialization

- (void)initializeNavigationItem;

#pragma mark - View configuration

- (void)enableLogIn:(BOOL)enabled;

#pragma mark - Logging in

- (void)attemptLogInWithUsername:(NSString *)username
                        password:(NSString *)password;

@end


@implementation TwitterLogInViewController

@synthesize delegate = delegate_;

@synthesize usernameCell = usernameCell_;
@synthesize usernameTextField = usernameTextField_;
@synthesize passwordCell = passwordCell_;
@synthesize passwordTextField = passwordTextField_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [usernameCell_ release];
    [usernameTextField_ release];
    [passwordCell_ release];
    [passwordTextField_ release];
    
    [super dealloc];
}

#pragma mark - Initialization

- (id)init
{
    self = [super initWithNibName:@"TwitterLogInView" bundle:nil];
    if (self)
        [self setTitle:NSLocalizedString(@"twitter.log-in.title", nil)];
    return self;
}

#pragma mark - UI events

- (void)cancel:(id)sender
{
    [[self delegate] twitterLogInViewControllerDidCancel:self];
}

- (void)done:(id)sender
{
    NSString *username = [[self usernameTextField] text];
    NSString *password = [[self passwordTextField] text];

    [self attemptLogInWithUsername:username password:password];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem];

    [[self usernameTextField] becomeFirstResponder];
    [self enableLogIn:NO];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

#pragma mark - UITableViewDataSource implementation

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath row] == 0)
        return [self usernameCell];
    else if ([indexPath row] == 1)
        return [self passwordCell];

    return nil;
}

#pragma mark - UITextFieldDelegate implementation

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    NSString *currentText = [textField text];
    NSString *text = [currentText stringByReplacingCharactersInRange:range
                                                          withString:string];

    NSString *otherText = nil;
    if (textField == [self usernameTextField])
        otherText = [[self passwordTextField] text];
    else if (textField == [self passwordTextField])
        otherText = [[self usernameTextField] text];
    [self enableLogIn:[text length] > 0 && [otherText length] > 0];

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self enableLogIn:NO];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == [self usernameTextField])
        [[self passwordTextField] becomeFirstResponder];
    else if (textField == [self passwordTextField]) {
        NSString *username = [[self usernameTextField] text];
        NSString *password = [[self passwordTextField] text];
        if ([username length] && [password length])
            [self attemptLogInWithUsername:username password:password];
    }

    return YES;
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

    UIBarButtonItem *doneButton =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                              target:self
                              action:@selector(done:)];
    [[self navigationItem] setRightBarButtonItem:doneButton];
    [doneButton release], doneButton = nil;
}

#pragma mark - View configuration

- (void)enableLogIn:(BOOL)enabled
{
    [[[self navigationItem] rightBarButtonItem] setEnabled:enabled];
}

#pragma mark - Logging in

- (void)attemptLogInWithUsername:(NSString *)username
                        password:(NSString *)password
{
    NSString *consumerKey = LokaliteTwitterOAuthConsumerKey;
    NSString *consumerSecret = LokaliteTwitterOAuthConsumerSecret;
    TwitterXauthenticator *authenticator =
        [[TwitterXauthenticator alloc] initWithConsumerKey:consumerKey
                                            consumerSecret:consumerSecret];
    [authenticator authWithUsername:username password:password];
}

#pragma mark - TwitterXauthenticatorDelegate implementation

- (void)xauthenticator:(TwitterXauthenticator *)xauthenticator
       didReceiveToken:(NSString *)key
                secret:(NSString *)secret
              username:(NSString *)username
                userId:(NSString *)userId
{
    NSLog(@"Username: %@", username);

    [xauthenticator autorelease];
}

- (void)xauthenticator:(TwitterXauthenticator *)xauthenticator
  failedToAuthUsername:(NSString *)username
           andPassword:(NSString *)password
                 error:(NSError *)error
{
    NSLog(@"Error: %@", error);

    [xauthenticator autorelease];
}

@end
