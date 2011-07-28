//
//  LogInViewController.m
//  Lokalite
//
//  Created by John Debay on 7/25/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LogInViewController.h"

#import "LokaliteAccount.h"
#import "LokaliteAccount+KeychainAdditions.h"

#import "LokaliteObjectBuilder.h"
#import "LokaliteService.h"

#import "SDKAdditions.h"

#import <CoreData/CoreData.h>

@interface LogInViewController ()

@property (nonatomic, retain) LokaliteService *service;

#pragma mark - View initialization

- (void)initializeNavigationItem:(UINavigationItem *)navItem;

#pragma mark - View configuration

- (void)configureInterfaceForUsername:(NSString *)username
                             password:(NSString *)password;

#pragma mark - Attempting to log in

- (void)attemptLogInWithUsername:(NSString *)username
                        password:(NSString *)password;
- (void)processLogInData:(NSDictionary *)data password:(NSString *)password;
- (void)processLogInError:(NSError *)error;

@end


@implementation LogInViewController

@synthesize delegate = delegate_;

@synthesize context = context_;

@synthesize usernameCell = usernameCell_;
@synthesize passwordCell = passwordCell_;
@synthesize usernameTextField = usernameTextField_;
@synthesize passwordTextField = passwordTextField_;

@synthesize service = service_;

#pragma mark - Memory management

- (void)dealloc
{
    delegate_ = nil;

    [usernameCell_ release];
    [passwordCell_ release];

    [usernameTextField_ release];
    [passwordTextField_ release];

    [service_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (id)initWithContext:(NSManagedObjectContext *)context
{
    self = [super initWithNibName:@"LogInView" bundle:nil];
    if (self) {
        context_ = [context retain];
        [self setTitle:NSLocalizedString(@"global.log-in", nil)];
    }

    return self;
}

#pragma mark - UI events

- (void)logIn:(id)sender
{
    [self attemptLogInWithUsername:[[self usernameTextField] text]
                          password:[[self passwordTextField] text]];
}

- (void)cancel:(id)sender
{
    [[self delegate] logInViewControllerDidCancel:self];
}

#pragma mark - UITableViewController implementation

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self initializeNavigationItem:[self navigationItem]];
    [self configureInterfaceForUsername:[[self usernameTextField] text]
                               password:[[self passwordTextField] text]];

    [[self usernameTextField] becomeFirstResponder];
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
    UITableViewCell *cell = nil;

    if ([indexPath row] == 0)
        cell = [self usernameCell];
    else if ([indexPath row] == 1)
        cell = [self passwordCell];

    return cell;
}

#pragma mark - UITextFieldDelegate implementation

- (BOOL)textField:(UITextField *)textField
    shouldChangeCharactersInRange:(NSRange)range
                replacementString:(NSString *)string
{
    NSString *username = [[self usernameTextField] text];
    NSString *password = [[self passwordTextField] text];

    BOOL isUsername = textField == [self usernameTextField];
    NSString *s = isUsername ? username : password;
    s = [s stringByReplacingCharactersInRange:range withString:string];
    if (isUsername)
        username = s;
    else
        password = s;

    [self configureInterfaceForUsername:username password:password];

    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    [self configureInterfaceForUsername:nil password:nil];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == [self usernameTextField])
        [[self passwordTextField] becomeFirstResponder];
    else
        [self attemptLogInWithUsername:[[self usernameTextField] text]
                              password:[[self passwordTextField] text]];

    return YES;
}

#pragma mark - View initialization

- (void)initializeNavigationItem:(UINavigationItem *)navItem
{
    UIBarButtonItem *cancelButton =
        [[UIBarButtonItem alloc]
         initWithBarButtonSystemItem:UIBarButtonSystemItemCancel
                              target:self
                              action:@selector(cancel:)];
    [navItem setLeftBarButtonItem:cancelButton];
    [cancelButton release], cancelButton = nil;

    UIBarButtonItem *logInButton =
        [[UIBarButtonItem alloc]
         initWithTitle:NSLocalizedString(@"global.log-in", nil)
                 style:UIBarButtonItemStyleDone
                target:self
                action:@selector(logIn:)];
    [navItem setRightBarButtonItem:logInButton];
    [logInButton release], logInButton = nil;
}

#pragma mark - View configuration

- (void)configureInterfaceForUsername:(NSString *)username
                             password:(NSString *)password
{
    BOOL enabled = [username length] > 0 && [password length] > 0;
    [[[self navigationItem] rightBarButtonItem] setEnabled:enabled];
}

#pragma mark - Attempting to log in

- (void)attemptLogInWithUsername:(NSString *)username
                        password:(NSString *)password
{
    NSLog(@"Attempting log in of user: '%@'", username);

    [[self usernameTextField] resignFirstResponder];
    [[self passwordTextField] resignFirstResponder];

    [self displayActivityViewWithCompletion:^{
        [[self service] setEmail:username password:password];
        [[self service] fetchProfileWithResponseHandler:
         ^(NSHTTPURLResponse *response, NSDictionary *data, NSError *error) {
             [self hideActivityView];
             if (data)
                 [self processLogInData:data password:password];
             else if (error)
                 [self processLogInError:error];
         }];
    }];
}

- (void)processLogInData:(NSDictionary *)data password:(NSString *)password
{
    LokaliteAccount *account =
        [LokaliteObjectBuilder
         createOrUpdateLokaliteAccountFromJsonData:data
                                         inContext:[self context]];
    [account setPassword:password];
    [[self delegate] logInViewController:self didLogInWithAccount:account];
}

- (void)processLogInError:(NSError *)error
{
    NSString *title = NSLocalizedString(@"log-in.failed", nil);
    NSString *message = [error localizedDescription];
    NSString *dismiss = NSLocalizedString(@"global.dismiss", nil);

    UIAlertView *alert =
        [[UIAlertView alloc] initWithTitle:title
                                   message:message
                                  delegate:nil
                         cancelButtonTitle:dismiss
                         otherButtonTitles:nil];
    [alert show];
    [alert release], alert = nil;

    [[self passwordTextField] becomeFirstResponder];
}

#pragma mark - Accessors

- (LokaliteService *)service
{
    if (!service_) {
        NSURL *baseUrl = [[UIApplication sharedApplication] baseLokaliteUrl];
        service_ = [[LokaliteService alloc] initWithBaseUrl:baseUrl];
    }

    return service_;
}

@end
