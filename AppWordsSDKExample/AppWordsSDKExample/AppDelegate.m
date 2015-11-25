//
//  AppDelegate.m
//  AppWordsSDKExample
//
//  Created by Amit Attias on 2/8/15.
//  Copyright (c) 2015 Deeplink. All rights reserved.
//

#import "AppDelegate.h"
#import <AppWordsSDK/AppWordsSDK.h>

#import "ApiConstants.h"
#import "SearchViewController.h"

#ifdef __IPHONE_9_0
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/UTCoreTypes.h>
#endif

@interface AppDelegate ()
@property (nonatomic) BOOL justLaunched;
@property (nonatomic) BOOL waitingForInstallationLink;
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    self.justLaunched = YES;
    self.waitingForInstallationLink = [AppWordsSDK getAssociatedInstallationLinkWithOptions:launchOptions appID:APP_ID timeout:1.0 completion:^(NSURL *url, NSError *error) {
        if (url != nil) {
            [self.window.rootViewController performSegueWithIdentifier:@"DeeplinkSegue" sender:url];
        }
        else {
            [self.window.rootViewController performSegueWithIdentifier:@"AppWordsSegue" sender:nil];
        }
    }];
    
//    [self.window.rootViewController performSegueWithIdentifier:@"WelcomeSegue" sender:nil];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.justLaunched) {
        self.justLaunched = NO;
        if (! self.waitingForInstallationLink) {
            [self.window.rootViewController performSegueWithIdentifier:@"AppWordsSegue" sender:nil];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    url = [AppWordsSDK handleOpenURL:url apiKey:API_KEY];
    return YES;
}

- (BOOL)application:(UIApplication *)application continueUserActivity:(NSUserActivity *)userActivity restorationHandler:(void(^)(NSArray *restorableObjects))restorationHandler {
    
    NSString *activityType = userActivity.activityType;
    if ([activityType isEqualToString:kDemoActivityType]) {
        // Handle restoration for values provided in userInfo
        if (self.window != nil) {
            [self.window.rootViewController restoreUserActivityState:userActivity];
        }
        return YES;
    }
#ifdef __IPHONE_9_0
    else if (&CSSearchableItemActionType != NULL && //iOS 9+
             [activityType isEqualToString:CSSearchableItemActionType]) {
        // This activity represents an item indexed using Core Spotlight, so restore the context related to the unique identifier.
//        // The unique identifier of the Core Spotlight item is set in the activity’s userInfo for the key CSSearchableItemActivityIdentifier.
//        NSString *uniqueIdentifier = [userActivity.userInfo objectForKey:CSSearchableItemActivityIdentifier];
        
        if (self.window != nil) {
            [self.window.rootViewController restoreUserActivityState:userActivity];
        }
        
        return YES;
    }
#endif
    return NO;
}
@end
