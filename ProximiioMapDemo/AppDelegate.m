//
//  AppDelegate.m
//  DemoWayFinding
//
//  Created by Office on 12/21/17.
//  Copyright © 2017 Office. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@import Proximiio;
@import UserNotifications;

@interface AppDelegate ()
@property (nonatomic, strong) ViewController *viewController;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //[Fabric with:@[[Crashlytics class]]];
    
    self.viewController = [[ViewController alloc] init];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    UINavigationController *navigationViewController = [[UINavigationController alloc]initWithRootViewController:self.viewController];
    [self.window setRootViewController:navigationViewController];
    self.window.backgroundColor = [UIColor colorWithWhite:0.97 alpha:1];
//    [self.window makeKeyAndVisible];
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    UNAuthorizationOptions options = UNAuthorizationOptionAlert + UNAuthorizationOptionSound;
    [center requestAuthorizationWithOptions:options
                          completionHandler:^(BOOL granted, NSError * _Nullable error) {
                              if (!granted) {
                                  NSLog(@"Something went wrong with notifications: %@", error);
                              }
                          }];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    [[Proximiio sharedInstance] extendBackgroundTime];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
