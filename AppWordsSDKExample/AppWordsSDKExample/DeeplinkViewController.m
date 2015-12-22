//
//  DeeplinkViewController.m
//  AppWordsSDKExample
//
//  Created by David Jacobson on 20/11/2015.
//  Copyright © 2015 Deeplink.me. All rights reserved.
//

#import "DeeplinkViewController.h"

#import "ViewController.h"

@implementation DeeplinkViewController

-(void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[ViewController class]])
    {
        ViewController *viewController = segue.destinationViewController;
        [viewController setKeywordsWithURL:self.url];
    }
}

-(void)restoreUserActivityState:(NSUserActivity *)activity {
    UIViewController *presentedViewController = [self presentedViewController];
    if (presentedViewController) {
        [presentedViewController restoreUserActivityState:activity];
    }
}

@end
