//
//  SearchViewController.m
//  AppWordsSDKExample
//
//  Created by David Jacobson on 11/08/2015.
//  Copyright © 2015 Deeplink.me. All rights reserved.
//

#import "SearchViewController.h"
#import <AppWordsSDK/AppWordsSDK.h>

#ifdef __IPHONE_9_0
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/UTCoreTypes.h>
#endif

NSString *kDemoActivityType = @"demo.appwordssdkexample.pages";

@interface SearchViewController () <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *titleTextField;
@property (strong, nonatomic) IBOutlet UITextField *descriptionTextField;
@property (strong, nonatomic) IBOutlet UITextField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UILabel *errorCode;
@property (weak, nonatomic) IBOutlet UITextView *errorMessage;

@end

@implementation SearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.errorMessage.font = [UIFont preferredFontForTextStyle:UIFontTextStyleBody];
    
    self.errorCode.text = @"";
    self.errorMessage.text = @"";
    
    if (self.userActivity != nil) {
        [self restoreTextFieldsFromActivity:self.userActivity];
    }
}

- (void)prepareForAPICall {
    [self.titleTextField resignFirstResponder];
    [self.descriptionTextField resignFirstResponder];
    [self.keywordsTextField resignFirstResponder];
}

- (IBAction)itemButtonClicked:(id)sender {
    if ([self.titleTextField.text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].length == 0 ||
        [self.descriptionTextField.text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].length == 0)
    {
        self.errorCode.text = @"<>";
        self.errorMessage.text = @"Title and Description must contain letters";
        return;
    }

    [self prepareForAPICall];
    
#ifdef __IPHONE_9_0
    if ([CSSearchableItemAttributeSet class]) {
        // Create a searchable item, specifying its ID, associated domain, and the attribute set you created earlier.
        CSSearchableItem *item = [[CSSearchableItem alloc] initWithUniqueIdentifier:[self webpageURL]
                                                                   domainIdentifier:@"appwordssdkexample_title_pages" // use your own!
                                                                       attributeSet:[self attributeSet]];
        item.expirationDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60]; // use a more appropriate date for your own pages!
        
        // Send the item to Apple for indexing
        [[CSSearchableIndex defaultSearchableIndex] indexSearchableItems:@[item] completionHandler: ^(NSError * __nullable error) {
            if (error) {
                NSLog(@"Apple failed to index search item");
            }
            else {
                NSLog(@"Apple indexed search item");
            }
        }];

        // Send the item to AppWords for indexing
        [[AppWordsSDK sharedInstance] addPublicallySearchableItem:item
                                                       webpageURL:[self webpageURL]
                                                         keywords:[self keywords]
                                                         imageURL:[self imageURL]
                                                       completion:^(NSError *error) {
                                                           [self reportError:error successMessage:@"CSSearchableItem added"];
                                                       }];
    }
#endif
    
}

- (IBAction)activityButtonClicked:(id)sender {
    if ([self.titleTextField.text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].length == 0 ||
        [self.descriptionTextField.text rangeOfCharacterFromSet:[NSCharacterSet letterCharacterSet]].length == 0)
    {
        self.errorCode.text = @"<>";
        self.errorMessage.text = @"Title and Description must contain letters";
        return;
    }

    [self prepareForAPICall];
    
    
#ifdef __IPHONE_9_0
    if ([CSSearchableItemAttributeSet class]) {
        CSSearchableItemAttributeSet *contentAttributeSet = self.attributeSet;
        contentAttributeSet.relatedUniqueIdentifier = self.webpageURL;

        [self.userActivity resignCurrent];
        self.userActivity = nil;
        
        self.userActivity = [[NSUserActivity alloc] initWithActivityType:kDemoActivityType]; // use your own!
        self.userActivity.requiredUserInfoKeys = [NSSet setWithArray:@[@"title", @"description", @"keywords"]];

        self.userActivity.contentAttributeSet = contentAttributeSet;

        self.userActivity.expirationDate = [NSDate dateWithTimeIntervalSinceNow:24*60*60]; // use a more appropriate date for your own pages!
        self.userActivity.webpageURL = [NSURL URLWithString:[self webpageURL]];
        self.userActivity.keywords = [self keywords];
        self.userActivity.title = [self title];

        self.userActivity.eligibleForHandoff = YES;
        self.userActivity.eligibleForSearch = YES;
        self.userActivity.eligibleForPublicIndexing = YES;

        self.userActivity.needsSave = YES;

        [self.userActivity becomeCurrent]; // Apple will index this activity, if not previously indexed; otherwise it will increase its search rank

        // Send the activity to AppWords for indexing
        [[AppWordsSDK sharedInstance] addUserActivity:self.userActivity imageURL:[self imageURL] completion:^(NSError *error)
         {
             [self reportError:error successMessage:@"NSUserActivity added"];
         }];
    }
#endif
    
}

- (void)restoreTextFieldsFromActivity:(NSUserActivity *)activity {
#ifdef __IPHONE_9_0
    self.userActivity.requiredUserInfoKeys = [NSSet setWithArray:@[@"title", @"description", @"keywords"]];
#endif

    self.titleTextField.text = self.userActivity.userInfo[@"title"];
    self.descriptionTextField.text = self.userActivity.userInfo[@"description"];
    self.keywordsTextField.text = self.userActivity.userInfo[@"keywords"];
}

- (void)restoreUserActivityState:(NSUserActivity *)activity {
    self.userActivity = activity;
    
    if ([self isViewLoaded]) {
        [self restoreTextFieldsFromActivity:activity];
    }
    
    [super restoreUserActivityState:activity];
}

- (void)updateUserActivityState:(nonnull NSUserActivity *)activity {
    self.userActivity.userInfo = @{@"title": self.titleTextField.text,
                                   @"description": self.descriptionTextField.text,
                                   @"keywords": self.keywordsTextField.text};
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Search parameters

// You will want to choose a real description/summary of your app page!
- (NSString *)title {
    return self.titleTextField.text;
}

// You will want to return a real webpage corresponding to the app page!
- (NSString *)webpageURL {
    NSString *base64 = [[self.titleTextField.text dataUsingEncoding:NSASCIIStringEncoding] base64EncodedStringWithOptions:0];
    NSString *safeBase64 = [base64 stringByReplacingOccurrencesOfString:@"/" withString:@"_"];
    return [NSString stringWithFormat:@"http://appwordssdkexample.demo/%@", safeBase64];
}

// You will want to return a real image url corresponding to the app page!
- (NSString *)imageURL {
    return @"http://deepsearch.me/images/logo.png";
}

// You will want to choose real keywords for your app pages!
- (NSSet*)keywords {
    NSRegularExpression *wordRegexp = [NSRegularExpression regularExpressionWithPattern:@"[A-Za-z0-9]+" options:0 error:nil];
    NSArray *matches = [wordRegexp matchesInString:self.keywordsTextField.text
                                                                  options:0
                                                                    range:NSMakeRange(0, self.keywordsTextField.text.length)];
    NSMutableSet *keywords = [NSMutableSet set];
    for (NSTextCheckingResult* match in matches) {
        [keywords addObject:[self.keywordsTextField.text substringWithRange:match.range]];
    }

    return keywords;
}

// You will want to choose a real description/summary of your app page!
- (NSString *)contentDescription {
    return self.descriptionTextField.text;
}

#ifdef __IPHONE_9_0
- (CSSearchableItemAttributeSet *)attributeSet {
    // Create an attribute set for an item that represents an article.
    CSSearchableItemAttributeSet* attributeSet = [[CSSearchableItemAttributeSet alloc] initWithItemContentType:(NSString *)kUTTypeURL];
    // Set properties that describe attributes of the item such as title, description, and image.
    
    attributeSet.title = self.title;
    attributeSet.contentDescription = self.contentDescription;
    
    // Dummy coordinates: use real ones!
    attributeSet.latitude = @-74.0132826;
    attributeSet.longitude = @40.7114927;

    return attributeSet;
}
#endif

- (void)reportError:(NSError *)error successMessage:(NSString *) successMessage {
    if (error) {
        self.errorCode.text = [NSString stringWithFormat:@"<%ld>", (long)error.code];
        self.errorMessage.text = [AppWordsSDK descriptionForError:error];
    }
    else if (successMessage != nil) {
        self.errorCode.text = @"<None>";
        self.errorMessage.text = successMessage;
    }
    else {
        self.errorCode.text = @"";
        self.errorMessage.text = @"";
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (textField == self.titleTextField) {
        [self.descriptionTextField becomeFirstResponder];
    }
    else if (textField == self.descriptionTextField) {
        [self.keywordsTextField becomeFirstResponder];
    }
    else {
        [textField resignFirstResponder];
    }
    return YES;

}

@end
