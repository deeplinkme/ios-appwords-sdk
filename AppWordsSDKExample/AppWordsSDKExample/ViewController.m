//
//  ViewController.m
//  AppWordsSDKExample
//
//  Created by Amit Attias on 2/8/15.
//  Copyright (c) 2015 Deeplink. All rights reserved.
//

#import "ViewController.h"
#import <AppWordsSDK/AppWordsSDK.h>

#import "ApiConstants.h"

#ifdef __IPHONE_9_0
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/UTCoreTypes.h>
#endif

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UIButton *gotoSearchWordsButton;
@property (weak, nonatomic) IBOutlet UIButton *linkButton;
@property (weak, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet UILabel *errorCode;
@property (weak, nonatomic) IBOutlet UITextView *errorMessage;

@property (strong, nonatomic) DLMELink *deeplink;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.errorMessage.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.createButton.enabled = NO;
    [self.linkButton setTitle:@"" forState:UIControlStateNormal];
    
    self.errorCode.text = @"";
    self.errorMessage.text = @"";
    [[AppWordsSDK sharedInstance] initializeWithApiKey:API_KEY andAppID:APP_ID completion:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                self.errorCode.text = [NSString stringWithFormat:@"<%ld>", (long)error.code];
                self.errorMessage.text = [AppWordsSDK descriptionForError:error];
            }
            else {
                self.errorCode.text = @"<None>";
                self.errorMessage.text = @"initializeWithApiKey succeeded";
                
                self.createButton.enabled = YES;
            }
        });
    }];
    self.createButton.enabled = YES;
#ifndef __IPHONE_9_0
    self.gotoSearchWordsButton.enabled = NO;
#endif
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
}

-(void)restoreUserActivityState:(NSUserActivity *)activity {
    UIViewController *presentedViewController = [self presentedViewController];
    if (presentedViewController) {
        [presentedViewController restoreUserActivityState:activity];
    }
    else {
        [self performSegueWithIdentifier:@"SearchWordsSegue" sender:activity];
        [super restoreUserActivityState:activity];
    }
}

-(void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[NSUserActivity class]])
    {
        [[segue destinationViewController] restoreUserActivityState:sender];
    }
}

- (IBAction)createButtonClicked:(id)sender {
    
    [self.keywordsTextField resignFirstResponder];
    
    self.errorCode.text = @"";
    self.errorMessage.text = @"";
    [[AppWordsSDK sharedInstance] getLinkWithKeywords:self.keywordsTextField.text completion:^(NSError *error, DLMELink *deeplink) {
        self.deeplink = deeplink;
        if (error) {
            self.errorCode.text = [NSString stringWithFormat:@"<%ld>", (long)error.code];
            self.errorMessage.text = [AppWordsSDK descriptionForError:error];
        }
        else {
            self.errorCode.text = @"<None>";
            self.errorMessage.text = @"getLinkWithKeywords succeeded";
            
            [self.linkButton setTitle:deeplink.host forState:UIControlStateNormal];
        }
    }];
}

- (IBAction)linkButtonClicked:(id)sender {
    [self.deeplink open:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
