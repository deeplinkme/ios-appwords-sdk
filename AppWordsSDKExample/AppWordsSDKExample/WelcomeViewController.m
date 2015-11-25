//
//  WelcomeViewController.m
//  AppWordsSDKExample
//
//  Created by David Jacobson on 17/11/2015.
//  Copyright © 2015 Deeplink.me. All rights reserved.
//

#import "WelcomeViewController.h"
#import "DeeplinkViewController.h"

@interface WelcomeViewController ()
@property (nonatomic) BOOL didAppear;
@property (nonatomic, copy) NSString *segueIdentifier;
@property (nonatomic) id segueSender;
@end

@implementation WelcomeViewController

- (void)viewDidAppear:(BOOL)animated {
    self.didAppear = YES;
    if (self.segueIdentifier) {
        NSString *identifier = self.segueIdentifier;
        id sender = self.segueSender;
        self.segueIdentifier = nil;
        self.segueSender = nil;
        [self performSegueWithIdentifier:identifier sender:sender];
    }
}

- (IBAction)unwindDeeplink:(UIStoryboardSegue *)unwindSegue
{
}

-(void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(NSURL *)url {
    if ([segue.destinationViewController isKindOfClass:[DeeplinkViewController class]])
    {
        DeeplinkViewController *viewController = segue.destinationViewController;
        viewController.url = url;
    }
}

-(void)restoreUserActivityState:(NSUserActivity *)activity {
    UIViewController *presentedViewController = [self presentedViewController];
    if (presentedViewController) {
        [presentedViewController restoreUserActivityState:activity];
    }
}

- (void)performSegueWithIdentifier:(NSString *)identifier sender:(id)sender {
    if (! self.didAppear) {
        // Need to cover up the view until we segue to the new
        UIView *view = [[[NSBundle mainBundle] loadNibNamed:@"LaunchScreen" owner:self options:nil] firstObject];
        view.translatesAutoresizingMaskIntoConstraints = NO;
        [self.view addSubview:view];
        NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[view]|" options:0 metrics:nil views:bindings]];
        [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[view]|" options:0 metrics:nil views:bindings]];
        
        self.segueIdentifier = identifier;
        self.segueSender = sender;
    }
    else {
        [super performSegueWithIdentifier:identifier sender:sender];
    }
}

@end
