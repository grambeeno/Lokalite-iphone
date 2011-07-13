//
//  LokaliteAppDelegate.m
//  Lokalite
//
//  Created by John Debay on 7/8/11.
//  Copyright 2011 Lokalite. All rights reserved.
//

#import "LokaliteAppDelegate.h"

#import <CoreData/CoreData.h>

#import "FeaturedViewController.h"

#import "SDKAdditions.h"

@interface LokaliteAppDelegate ()

@property (nonatomic, retain) NSManagedObjectModel *model;
@property (nonatomic, retain) NSPersistentStoreCoordinator *coordinator;
@property (nonatomic, retain) NSManagedObjectContext *context;

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

#pragma mark - Memory management

- (void)dealloc
{
    [window_ release];
    [tabBarController_ release];

    [model_ release];
    [coordinator_ release];
    [context_ release];

    [super dealloc];
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];

    UIColor *navBarTintColor = [UIColor navigationBarTintColor];
    UITabBarController *tabBarController = [self tabBarController];
    __block FeaturedViewController *featuredController = nil;
    [[tabBarController viewControllers] enumerateObjectsUsingBlock:
     ^(UIViewController *controller, NSUInteger idx, BOOL *stop) {
         if ([controller isKindOfClass:[UINavigationController class]]) {
             UINavigationController *nc = (UINavigationController *) controller;
             [[nc navigationBar] setTintColor:navBarTintColor];

             controller = [nc topViewController];
         }

         if ([controller isKindOfClass:[FeaturedViewController class]])
             featuredController = (FeaturedViewController *) controller;
     }];

    [featuredController setContext:[self context]];
}

#pragma mark - UIApplicationDelegate implementation

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
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
