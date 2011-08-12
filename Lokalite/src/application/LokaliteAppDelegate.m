//
//  LokaliteAppDelegate.m
//  Lokalite
//
//  Created by John Debay on 7/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteAppDelegate.h"

#import <CoreData/CoreData.h>

#import "FeaturedEventsViewController.h"
#import "TrendingViewController.h"
#import "EventsViewController.h"
#import "PlacesViewController.h"
#import "ProfileViewController.h"

#import "ActivityView.h"

#import "LokaliteApplicationState.h"

#import "LokaliteAccount.h"
#import "Event.h"
#import "Business.h"
#import "LokaliteDownloadSource.h"

#import "LokaliteShared.h"
#import "SDKAdditions.h"

static const NSInteger PROFILE_TAB_BAR_ITEM_INDEX = 4;

@interface LokaliteAppDelegate ()

@property (nonatomic, retain) NSManagedObjectModel *model;
@property (nonatomic, retain) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic, retain) DeviceLocator *deviceLocator;

#pragma mark - Location management

- (void)startLocatingDevice;
- (void)stopLocatingDevice;

#pragma mark - User interface management

- (void)initializeTabBarController:(UITabBarController *)tabBarController;

- (void)updateInterfaceForNoAccount;
- (void)updateInterfaceForAccount:(LokaliteAccount *)account;
- (void)exchangeTabBarViewControllerAtIndex:(NSInteger)index
                         withViewController:(UIViewController *)controller;

#pragma mark - Account management

- (void)processAccountAddition:(LokaliteAccount *)account;
- (void)processAccountDeletion:(LokaliteAccount *)account;

#pragma mark - Persistence management

- (NSDate *)currentFreshnessDate;
- (void)setDataFreshnessRequirementToDate:(NSDate *)date;

- (void)deleteAllEventAndBusinessData;
- (void)deleteAllEventAndBusinessDataLessFreshThanDate:(NSDate *)date;
- (void)deleteStaleData;

- (void)saveContext;

- (void)subscribeForNotificationsForContext:(NSManagedObjectContext *)context;
- (void)unsubscribeForNotoficationsForContext:(NSManagedObjectContext *)context;

#pragma mark - Static accessors

+ (NSString *)modelPath;
+ (NSString *)persistentStorePath;

@end

@implementation LokaliteAppDelegate

@synthesize window = window_;
@synthesize tabBarController = tabBarController_;

@synthesize model = model_;
@synthesize coordinator = coordinator_;
@synthesize context = context_;

@synthesize deviceLocator = deviceLocator_;

#pragma mark - Memory management

- (void)dealloc
{
    [window_ release];
    [tabBarController_ release];

    [model_ release];
    [coordinator_ release];
    [context_ release];

    [deviceLocator_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];

    UIColor *navBarTintColor = [UIColor navigationBarTintColor];
    UITabBarController *tabBarController = [self tabBarController];
    NSManagedObjectContext *context = [self context];

    [[tabBarController viewControllers] enumerateObjectsUsingBlock:
     ^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
         if ([controller isKindOfClass:[UINavigationController class]]) {
             UINavigationController *nc = (UINavigationController *) controller;
             [[nc navigationBar] setTintColor:navBarTintColor];

             controller = [nc topViewController];
         }

         if ([controller respondsToSelector:@selector(setContext:)])
             [controller setValue:context forKey:@"context"];
     }];
}

#pragma mark - UIApplicationDelegate implementation

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSDate *freshnessDate = [NSDate date];
    [self setDataFreshnessRequirementToDate:freshnessDate];

    [self deleteStaleData];

    [self subscribeForNotificationsForContext:[self context]];
    [self startLocatingDevice];

    [self initializeTabBarController:[self tabBarController]];

    [[self window] setRootViewController:[self tabBarController]];
    [[self window] makeKeyAndVisible];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state.
     This can occur for certain types of temporary interruptions (such as an
     incoming phone call or SMS message) or when the user quits the application
     and it begins the transition to the background state.

     Use this method to pause ongoing tasks, disable timers, and throttle down
     OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate
     timers, and store enough application state information to restore your
     application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called
     instead of applicationWillTerminate: when the user quits.
     */

    [self saveContext];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state;
     here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the
     application was inactive. If the application was previously in the
     background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

#pragma mark - AccountDetailsViewControllerDelegate implementation

- (void)accountDetailsViewController:(AccountDetailsViewController *)controller
                       logOutAccount:(LokaliteAccount *)account
{
    NSString *title = nil;
    NSString *cancelTitle = NSLocalizedString(@"global.cancel", nil);
    NSString *logOutTitle = NSLocalizedString(@"global.log-out", nil);

    UIActionSheet *sheet =
        [[UIActionSheet alloc] initWithTitle:title
                                    delegate:self
                           cancelButtonTitle:cancelTitle
                      destructiveButtonTitle:logOutTitle
                           otherButtonTitles:nil];

    [sheet showFromTabBar:[[self tabBarController] tabBar]];
    [sheet release], sheet = nil;
}

#pragma mark - DeviceLocatorDelegate implementation

- (void)deviceLocator:(DeviceLocator *)locator
     didUpateLocation:(CLLocation *)location
{
    /*
    NSDictionary *userInfo =
        [NSDictionary dictionaryWithObject:location forKey:DeviceLocationKey];
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc postNotificationName:DeviceLocationChangedNotification
                      object:self
                    userInfo:userInfo];
     */

    [[self deviceLocator] stop];
}

- (void)deviceLocator:(DeviceLocator *)locator
     didFailWithError:(NSError *)error
{
}

#pragma mark - Location management

- (void)startLocatingDevice
{
    [[self deviceLocator] start];
}

- (void)stopLocatingDevice
{
    [[self deviceLocator] stop];
}

#pragma mark - User interface management

- (void)initializeTabBarController:(UITabBarController *)tabBarController
{
    LokaliteAccount *account =
        [LokaliteAccount findFirstWithPredicate:nil inContext:[self context]];

    if (account)
        [self updateInterfaceForAccount:account];
}

- (void)updateInterfaceForNoAccount
{
    ProfileViewController *controller = [[ProfileViewController alloc] init];
    [controller setContext:[self context]];
    UINavigationController *nc =
        [[UINavigationController alloc] initWithRootViewController:controller];

    [self exchangeTabBarViewControllerAtIndex:PROFILE_TAB_BAR_ITEM_INDEX
                           withViewController:nc];

    [nc release], nc = nil;
    [controller release], controller = nil;
}

- (void)updateInterfaceForAccount:(LokaliteAccount *)account
{
    AccountDetailsViewController *controller =
        [[AccountDetailsViewController alloc] initWithAccount:account];
    [controller setDelegate:self];
    UINavigationController *nc =
        [[UINavigationController alloc] initWithRootViewController:controller];

    [self exchangeTabBarViewControllerAtIndex:PROFILE_TAB_BAR_ITEM_INDEX
                           withViewController:nc];

    [nc release], nc = nil;
    [controller release], controller = nil;
}

- (void)exchangeTabBarViewControllerAtIndex:(NSInteger)index
                         withViewController:(UIViewController *)controller
{
    NSMutableArray *viewControllers =
        [[[self tabBarController] viewControllers] mutableCopy];

    UITabBarItem *tabBarItem =
        [[viewControllers objectAtIndex:index] tabBarItem];
    [controller setTabBarItem:tabBarItem];

    [viewControllers replaceObjectAtIndex:index withObject:controller];
    [[self tabBarController] setViewControllers:viewControllers];

    [viewControllers release], viewControllers = nil;
}

#pragma mark - Account management

- (void)processAccountAddition:(LokaliteAccount *)account
{
    [self updateInterfaceForAccount:account];
}

- (void)processAccountDeletion:(LokaliteAccount *)account
{
    [self updateInterfaceForNoAccount];
}

#pragma mark - Persistence management

- (void)managedObjectContextDidChange:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];

    NSArray *insertedObjects = [userInfo objectForKey:NSInsertedObjectsKey];
    [insertedObjects enumerateObjectsUsingBlock:
     ^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
         if ([obj isKindOfClass:[LokaliteAccount class]]) {
             LokaliteAccount *account = (LokaliteAccount *) obj;
             [self processAccountAddition:account];
         }
     }];

    NSArray *deletedObjects = [userInfo objectForKey:NSDeletedObjectsKey];
    [deletedObjects enumerateObjectsUsingBlock:
     ^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
         if ([obj isKindOfClass:[LokaliteAccount class]]) {
             LokaliteAccount *account = (LokaliteAccount *) obj;
             [self processAccountDeletion:account];
         }
     }];
}

- (void)subscribeForNotificationsForContext:(NSManagedObjectContext *)context
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
           selector:@selector(managedObjectContextDidChange:)
               name:NSManagedObjectContextObjectsDidChangeNotification
             object:context];
}

- (void)unsubscribeForNotoficationsForContext:(NSManagedObjectContext *)context
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self
                  name:NSManagedObjectContextObjectsDidChangeNotification
                object:context];
}

- (NSDate *)currentFreshnessDate
{
    LokaliteApplicationState *appState =
        [LokaliteApplicationState currentState:[self context]];
    return [appState dataFreshnessDate];
}

- (void)setDataFreshnessRequirementToDate:(NSDate *)date
{
    LokaliteApplicationState *appState =
        [LokaliteApplicationState currentState:[self context]];
    [appState setDataFreshnessDate:date];
}
     
- (void)deleteAllEventAndBusinessData
{
    [self deleteAllEventAndBusinessDataLessFreshThanDate:nil];
}

- (void)deleteAllEventAndBusinessDataLessFreshThanDate:(NSDate *)date
{
    NSManagedObjectContext *context = [self context];

    void (^deleteObject)(id, NSUInteger, BOOL *) =
        ^(NSManagedObject *obj, NSUInteger idx, BOOL *stop) {
            NSLog(@"Deleting %@ with ID %@: %@", NSStringFromClass([obj class]),
                  [obj valueForKey:@"identifier"], [obj valueForKey:@"name"]);
            [context deleteObject:obj];
        };

    NSPredicate *pred = nil;
    if (date)
        [NSPredicate predicateWithFormat:
         @"(SUBQUERY(downloadSources, $source, "
           "$source.lastUpdated < %@).@count != 0)", date];

    NSArray *events = [Event findAllWithPredicate:pred inContext:context];
    [events enumerateObjectsUsingBlock:deleteObject];

    NSArray *businesses = [Business findAllWithPredicate:pred inContext:context];
    [businesses enumerateObjectsUsingBlock:deleteObject];
}

- (void)deleteStaleData
{
    NSDate *freshnessDate = [self currentFreshnessDate];
    [self deleteAllEventAndBusinessDataLessFreshThanDate:freshnessDate];
}

- (void)saveContext
{
    NSManagedObjectContext *context = [self context];
    if ([context hasChanges]) {
        NSError *error = nil;
        NSLog(@"Saving context...");
        if ([context save:&error])
            NSLog(@"Done");
        else
            NSLog(@"WARNING: Failed to save managed object context: %@",
                  [error detailedDescription]);
    } else
        NSLog(@"Context has no changes; not saving.");
}

#pragma mark - Displaying the application activity view

+ (NSInteger)activityViewTag
{
    return 201;
}

+ (NSTimeInterval)activityAnimationDuration
{
    return 0.3;
}

- (void)displayActivityViewAnimated:(BOOL)animated
{
    [self displayActivityViewAnimated:animated completion:nil];
}

- (void)displayActivityViewAnimated:(BOOL)animated
                         completion:(void(^)(void))completion
{
    CGRect frame = [[UIScreen mainScreen] applicationFrame];
    ActivityView *view = [[ActivityView alloc] initWithFrame:frame];
    [view setTag:[[self class] activityViewTag]];
    [view setAlpha:0];

    NSTimeInterval duration =
        animated ? [[self class] activityAnimationDuration] : 0;
    [UIView animateWithDuration:duration
                     animations:^{ [view setAlpha:1]; }
                     completion:^(BOOL done) { if (completion) completion(); }];
    [view showActivityIndicatorWithAnimationDuration:duration];

    [[self window] addSubview:view];
    [view release], view = nil;
}

- (void)hideActivityViewAnimated:(BOOL)animated
{
    [self hideActivityViewAnimated:animated completion:nil];
}

- (void)hideActivityViewAnimated:(BOOL)animated
                      completion:(void(^)(void))completion
{
    NSInteger tag = [[self class] activityViewTag];
    ActivityView * view = (ActivityView *) [[self window] viewWithTag:tag];

    if (view) {
        NSTimeInterval duration =
            animated ? [[self class] activityAnimationDuration] : 0;
        [UIView animateWithDuration:duration
                         animations:^{ [view setAlpha:0]; }
                         completion:^(BOOL done) {
                             [view removeFromSuperview];
                             if (completion)
                                 completion();
                         }];
        [view hideActivityIndicatorWithAnimationDuration:duration];
    }
}

#pragma mark - UIActionSheetDelegate implementation

- (void)actionSheet:(UIActionSheet *)actionSheet
    willDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {  // log out confirmed
        LokaliteAccount *account =
            [LokaliteAccount findFirstWithPredicate:nil
                                          inContext:[self context]];
        [[self context] deleteObject:account];
    }
}

#pragma mark - Accessors

- (NSManagedObjectContext *)context
{
    if (context_ != nil)
        return context_;

    NSPersistentStoreCoordinator * coordinator = [self coordinator];
    if (coordinator != nil) {
        context_ = [[NSManagedObjectContext alloc] init];
        [context_ setPersistentStoreCoordinator:coordinator];
    }

    return context_;
}

- (NSManagedObjectModel *)model
{
    if (model_ != nil)
        return model_;

    NSString * modelPath = [[self class] modelPath];
    NSURL * modelUrl = [NSURL fileURLWithPath:modelPath];
    model_ = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];

    return model_;
}

- (NSPersistentStoreCoordinator *)coordinator
{
    if (coordinator_ != nil)
        return coordinator_;

    NSString * path = [[self class] persistentStorePath];
    NSURL * storeURL = [NSURL fileURLWithPath:path];

    NSManagedObjectModel * model = [self model];

    NSError * error = nil;
    coordinator_ =
        [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];

    NSString * storeType = NSSQLiteStoreType;
    NSDictionary * options =
        [NSDictionary dictionaryWithObjectsAndKeys:
         [NSNumber numberWithBool:YES],
         NSMigratePersistentStoresAutomaticallyOption,
         [NSNumber numberWithBool:YES],
         NSInferMappingModelAutomaticallyOption, nil];

    NSPersistentStore * store =
        [coordinator_ addPersistentStoreWithType:storeType
                                   configuration:nil
                                             URL:storeURL
                                         options:options
                                           error:&error];
    if (!store) {
        // We failed to open the store, so delete the current one and re-create
        // it. If that fails, then we're done.
        NSLog(@"WARNING: Failed to create persistent store. Error:\n%@",
              [error detailedDescription]);
        NSLog(@"Attempting to delete current store (if it exists) and create a "
               "new one. Current store path: '%@'", path);
        NSFileManager *mgr = [NSFileManager defaultManager];
        if ([mgr fileExistsAtPath:path]) {
            if ([mgr removeItemAtPath:path error:&error]) {
                // try to create the store again
                NSLog(@"Successfully removed store. Attempting to create a new "
                      "one.");
                store =
                    [coordinator_
                     addPersistentStoreWithType:storeType
                                  configuration:nil
                                            URL:storeURL
                                        options:options
                                          error:&error];
            } else
                NSLog(@"Failed to delete file at path, even though it "
                       "exists. Error: %@", [error detailedDescription]);
        }

        if (!store) {
            NSLog(@"Unresolved error: %@", [error detailedDescription]);
            abort();
        }
    }

    return coordinator_;
}

- (DeviceLocator *)deviceLocator
{
    if (!deviceLocator_)
        deviceLocator_ = [[DeviceLocator locator] retain];

    return deviceLocator_;
}

#pragma mark - Static accessors

+ (NSString *)modelPath
{
    return [[NSBundle mainBundle] pathForResource:@"lokalite" ofType:@"momd"];
}

+ (NSString *)persistentStorePath
{
    NSString *docsDir = [UIApplication applicationDocumentsDirectory];
    return [docsDir stringByAppendingPathComponent:@"lokalite.sqlite"];
}

@end
