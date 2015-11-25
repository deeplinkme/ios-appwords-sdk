//
//  ViewController.m
//  AppWordsSDKExample
//
//  Created by Amit Attias on 2/8/15.
//  Copyright (c) 2015 Deeplink. All rights reserved.
//

#import "ViewController.h"
#import <AppWordsSDK/AppWordsSDK.h>
#import <AppWordsSDK/DLMEView.h>
#import <AppWordsSDK/DLMEViewLight.h>
#import "CardsView.h"
#import <CoreLocation/CoreLocation.h>

#import "ApiConstants.h"

#import "UIView+DLME_IB_CATEGORY.h"

#ifdef __IPHONE_9_0
#import <CoreSpotlight/CoreSpotlight.h>
#import <MobileCoreServices/UTCoreTypes.h>
#endif

@interface SearchField : UITextField
@property (nonatomic, assign) UIEdgeInsets edgeInsets;
@end

@implementation SearchField

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.edgeInsets = UIEdgeInsetsZero;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self){
        self.edgeInsets = UIEdgeInsetsZero;
    }
    return self;
}

- (CGRect)textRectForBounds:(CGRect)bounds {
    return [super textRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

- (CGRect)editingRectForBounds:(CGRect)bounds {
    return [super editingRectForBounds:UIEdgeInsetsInsetRect(bounds, self.edgeInsets)];
}

@end

@interface ViewController () <UITextViewDelegate, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UIButton *gotoSearchWordsButton;
@property (weak, nonatomic) IBOutlet UIView *resultView;
@property (weak, nonatomic) IBOutlet UISwitch *switchButton;
@property (weak, nonatomic) IBOutlet UIView *contentsView;
@property (weak, nonatomic) IBOutlet UITextView *logView;
@property (weak, nonatomic) IBOutlet SearchField *keywordsTextField;
@property (weak, nonatomic) IBOutlet UIButton *createButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentsViewWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentsViewHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentsViewYConstraint;

@property (weak, nonatomic) CardsView *actionSheet;
@property (weak, nonatomic) NSLayoutConstraint *actionSheetYConstraint;
@property (weak, nonatomic) UITapGestureRecognizer* tapGesture;
@property (weak, nonatomic) UIButton *locationButton;

@property (strong, nonatomic) DLMELink *deeplink;
@property (strong, nonatomic) CLLocationManager *locationManager;

@property (nonatomic, getter=isLocationEnabled) BOOL locationEnabled;
@property (nonatomic) float longitude;

- (IBAction)onSwitchUI:(id)sender;
- (IBAction)onEditSearch:(id)sender;

@property (nonatomic) float latitude;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.locationEnabled = NO;
    
    [self setupUI];
    [self setupLocationServices];

    [[AppWordsSDK sharedInstance] initializeWithApiKey:API_KEY andAppID:APP_ID completion:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (error) {
                NSString *errorCode = [NSString stringWithFormat:@"<%ld>", (long)error.code];
                [self addErrorMessageWithCode: errorCode andText:[NSString stringWithFormat:@"%@", [AppWordsSDK descriptionForError:error]]];
            }
            else {
                NSString* errorCode = @"<None>";
                [self addErrorMessageWithCode:errorCode andText:@"initializeWithApiKey succeeded"];
                [self updateCreateButton];
            }
        });
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    if (self.presentedViewController != nil) {
        [self setupLocationServices];
    }
}

-(void) setupUI
{
    float horizInset = 10;
    self.logView.contentInset = UIEdgeInsetsMake(6, horizInset, 0, 0);
    self.logView.contentSize = CGSizeMake(self.logView.contentSize.width-2*horizInset, self.logView.contentSize.height);
    [self.logView dlmeRoundCorners];

    UIImage* btnImage = [UIImage imageNamed:@"location_off_icon.png"];
    CGRect frame = CGRectMake(0, 0, btnImage.size.width*4, btnImage.size.height);
    // need (strong) local variable because property is weak
    UIButton *locationButton = [[UIButton alloc] initWithFrame:frame];
    [locationButton setImage:btnImage forState:UIControlStateNormal];
    [locationButton addTarget:self action:@selector(onLocation) forControlEvents:UIControlEventTouchUpInside];
    self.locationButton = locationButton;

    self.keywordsTextField.rightView = locationButton;
    self.keywordsTextField.rightViewMode = UITextFieldViewModeAlways;
    self.keywordsTextField.text = @"";
    if (self.url != nil) {
        NSArray<NSString *> *components = [[self.url absoluteString] componentsSeparatedByString:@"AppWordsSDKexample:/"];
        if (components.count == 2 && components[0].length == 0) {
            self.keywordsTextField.text = [components[1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    self.keywordsTextField.edgeInsets = UIEdgeInsetsMake(0, 14, 0, 0);
    self.keywordsTextField.layer.borderWidth = 1;
    self.keywordsTextField.layer.borderColor = [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1].CGColor;
    

    self.createButton.enabled = YES;
    self.createButton.alpha = 0.6;
    [self.createButton dlmeRoundCorners];
    
    // need (strong) local variable because property is weak
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
    [self.view addGestureRecognizer:tapGesture];
    self.tapGesture = tapGesture;
    
#ifdef __IPHONE_9_0
    if ([CSSearchableItemAttributeSet class] == nil) {
        self.gotoSearchWordsButton.enabled = NO;
    }
#endif
}

-(void) setupLocationServices
{
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
            [self.locationManager requestWhenInUseAuthorization];
            [self.locationManager requestAlwaysAuthorization];
        }
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.pausesLocationUpdatesAutomatically = YES;
    }
}

-(void) onLocation
{
    self.locationEnabled = !self.locationEnabled;
    if (self.locationEnabled) {
        [self.locationManager startUpdatingLocation];
        UIImage* btnImage = [UIImage imageNamed:@"location_on_icon.png"];
        [self.locationButton setImage:btnImage forState:UIControlStateNormal];
    } else {
        UIImage* btnImage = [UIImage imageNamed:@"location_off_icon.png"];
        [self.locationManager stopUpdatingLocation];
        [self.locationButton setImage:btnImage forState:UIControlStateNormal];
    }
    
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
}

-(void)prepareForSegue:(nonnull UIStoryboardSegue *)segue sender:(id)sender {
    if ([sender isKindOfClass:[NSUserActivity class]])
    {
        [[segue destinationViewController] restoreUserActivityState:sender];
    }
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

-(void) addErrorMessageWithCode:(NSString*) errorCode andText:(NSString *)errorMessage
{
    NSString* strLog = [NSString stringWithFormat:@"ERROR CODE: %@\nMESSAGE: %@\n", errorCode, errorMessage];
    
    NSDictionary* attributes = @{
                                 NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue-Bold" size:11]
                                 };
    NSMutableAttributedString* attrLogText = [[NSMutableAttributedString alloc] initWithString:strLog];
    
    NSRange errRange = [strLog rangeOfString:@"ERROR CODE:"];
    NSRange rangeError;
    rangeError.length = errorCode.length;
    rangeError.location = errRange.length + 1;
    
    NSRange msgRange = [strLog rangeOfString:@"MESSAGE:"];
    NSRange rangeMessage;
    rangeMessage.length = errorMessage.length;
    rangeMessage.location = 1 + msgRange.location + msgRange.length;
    
    
    NSDictionary* attrFont = @{ NSFontAttributeName:[UIFont fontWithName:@"HelveticaNeue" size:11] };
    NSRange range;
    range.location = 0;
    range.length = strLog.length;
    [attrLogText addAttributes:attrFont range:range];
    
    [attrLogText addAttributes:attributes range:rangeMessage];
    [attrLogText addAttributes:attributes range:rangeError];
    
    NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
    [style setLineSpacing:4];
    [attrLogText addAttribute:NSParagraphStyleAttributeName
                       value:style
                       range:NSMakeRange(0, attrLogText.length)];
    
    NSMutableAttributedString *text = [self.logView.attributedText mutableCopy];
    [text appendAttributedString:attrLogText];
    
    
    [self.logView setAttributedText:text];
    
    self.logView.textColor = [UIColor colorWithRed:199.0/255.0 green:37.0/255.0 blue:78.0/255.0 alpha:255.0/255.0];
    [self.logView scrollRangeToVisible:NSMakeRange([self.logView.attributedText length], 0)];
}

#pragma mark - Location Services
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"didFailWithError: %@", error);
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:@"Error" message:@"Failed to Get Your Location" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"didUpdateToLocation: %@", newLocation);
    CLLocation *currentLocation = newLocation;
    
    if (currentLocation != nil) {
        // Dummy coordinates: use real ones!
//        self.longitude = -74.0132826;
//        self.latitude = 40.7114927;

        self.longitude = currentLocation.coordinate.longitude;
        self.latitude = currentLocation.coordinate.latitude;
    }
}

#pragma mark -

-(void) onTap:(UITapGestureRecognizer*) gesture
{
    if (self.actionSheet) {
        [self slideOut];
    }
}

- (IBAction)createButtonClicked:(id)sender {
    
    [self.keywordsTextField resignFirstResponder];
    
    [self getDeeplink];
    if ([self.switchButton isOn]) {
        [self getDeeplink];
        [self getDeeplink];
    }
    else {
        self.deeplink = nil;
    }
}

// For iOS 8+
- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator
{
    if (self.actionSheet != nil) {
        // current width is new height
        self.contentsViewYConstraint.constant = 20 - self.view.bounds.size.width/4;
    }
    [self.actionSheet.collectionView reloadData];

    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
}

// For iOS 7
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
                                duration:(NSTimeInterval)duration
{
    if (self.actionSheet != nil) {
        // current width is new height
        self.contentsViewYConstraint.constant = 20 - self.view.bounds.size.width/4;
    }
    [self.actionSheet.collectionView reloadData];

    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark - ActionSheet

-(void) getDeeplink
{
    NSString* keywords = self.keywordsTextField.text;
    if (self.locationEnabled) {
        keywords = [NSString stringWithFormat:@"%@ @%f,%f", keywords, self.latitude, self.longitude];
    }
    
    [[AppWordsSDK sharedInstance] getLinkWithKeywords:keywords completion:^(NSError *error, DLMELink *deeplink) {
        
        if (error) {
            NSString* errorCode = [NSString stringWithFormat:@"<%ld>", (long)error.code];
            [self addErrorMessageWithCode:errorCode andText:[NSString stringWithFormat:@"%@", [AppWordsSDK descriptionForError:error]]];
        }
        else {
            NSString* errorCode = @"<None>";
            [self addErrorMessageWithCode:errorCode andText:@"getLinkWithKeywords succeeded"];
            if (self.deeplink == nil)
            {
                self.deeplink = deeplink;
                [self renderUI];
            }
            else {
                [self.actionSheet addDeeplink:deeplink];
            }
        }
    }];
}

-(void) slideIn {
    // need (strong) local variable because property is weak
    CardsView *actionSheet = [[[NSBundle mainBundle] loadNibNamed:@"CardsView" owner:self options:nil] firstObject];
    actionSheet.translatesAutoresizingMaskIntoConstraints = NO;
    [actionSheet addDeeplink:self.deeplink];
    [self.view addSubview:actionSheet];
    self.actionSheet = actionSheet;
    UICollectionViewFlowLayout *defaultLayout = (UICollectionViewFlowLayout *)self.actionSheet.collectionView.collectionViewLayout;
    UICollectionViewFlowLayout *transitionLayout = [[UICollectionViewFlowLayout alloc] init];
    transitionLayout.itemSize = defaultLayout.itemSize;
    transitionLayout.minimumInteritemSpacing = defaultLayout.minimumInteritemSpacing;
    transitionLayout.minimumLineSpacing = defaultLayout.minimumLineSpacing;
    transitionLayout.sectionInset = UIEdgeInsetsMake(self.view.bounds.size.height, 0, 0, 0);
    self.actionSheet.collectionView.collectionViewLayout = transitionLayout;

    NSMutableArray<NSLayoutConstraint*> *constraints = [NSMutableArray array];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.actionSheet attribute:NSLayoutAttributeWidth
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view    attribute:NSLayoutAttributeWidth
                                                       multiplier:1
                                                         constant:-20]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.actionSheet attribute:NSLayoutAttributeHeight
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view    attribute:NSLayoutAttributeHeight
                                                       multiplier:1
                                                         constant:0]];
    [constraints addObject:[NSLayoutConstraint constraintWithItem:self.actionSheet attribute:NSLayoutAttributeCenterX
                                                        relatedBy:NSLayoutRelationEqual
                                                           toItem:self.view    attribute:NSLayoutAttributeCenterX
                                                       multiplier:1
                                                         constant:0]];
    // need (strong) local variable because property is weak
    NSLayoutConstraint *actionSheetYConstraint = [NSLayoutConstraint constraintWithItem:self.actionSheet
                                                                              attribute:NSLayoutAttributeCenterY
                                                                              relatedBy:NSLayoutRelationEqual
                                                                                 toItem:self.view
                                                                              attribute:NSLayoutAttributeCenterY
                                                                             multiplier:1
                                                                               constant:0];
    [constraints addObject:actionSheetYConstraint];
    self.actionSheetYConstraint = actionSheetYConstraint;
    [self.view addConstraints:constraints];
    [self.view layoutIfNeeded];

    [UIView animateKeyframesWithDuration:0.3
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModePaced
                              animations:^{
                                  self.contentsView.transform = CGAffineTransformMakeScale(0.5, 0.5);;
                                  self.contentsViewYConstraint.constant = 20 - self.view.bounds.size.height/4;
                                  if (! [self respondsToSelector:@selector(presentationController)]) {
                                      // iOS 7 only
                                      [self.view removeConstraint:self.contentsViewWidthConstraint];
                                      NSLayoutConstraint *widthConstraint =
                                                          [NSLayoutConstraint constraintWithItem:self.contentsView
                                                                                       attribute:NSLayoutAttributeWidth
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.view
                                                                                       attribute:NSLayoutAttributeWidth
                                                                                      multiplier:0.5
                                                                                        constant:0];
                                      [self.view addConstraint:widthConstraint];
                                      self.contentsViewWidthConstraint = widthConstraint;

                                      [self.view removeConstraint:self.contentsViewHeightConstraint];
                                      NSLayoutConstraint *heightConstraint =
                                                          [NSLayoutConstraint constraintWithItem:self.contentsView
                                                                                       attribute:NSLayoutAttributeHeight
                                                                                       relatedBy:NSLayoutRelationEqual
                                                                                          toItem:self.view
                                                                                       attribute:NSLayoutAttributeHeight
                                                                                      multiplier:0.5
                                                                                        constant:0];
                                      [self.view addConstraint:heightConstraint];
                                      self.contentsViewHeightConstraint = heightConstraint;
                                  }
                                  [self.view layoutIfNeeded];
                              }
                              completion:^(BOOL finished) {
                                  [self.actionSheet.collectionView setCollectionViewLayout:defaultLayout animated:YES];
                              }];
}

-(void) slideOut {
    CGRect frame = self.actionSheet.frame;
    frame.origin = CGPointMake(0.0, self.view.bounds.size.height);
    
    [UIView animateKeyframesWithDuration:0.3
                                   delay:0
                                 options:UIViewKeyframeAnimationOptionCalculationModePaced
                              animations:^{
                                  self.contentsView.transform = CGAffineTransformMakeScale(1.0, 1.0);
                                  self.contentsViewYConstraint.constant = 0;
                                  self.actionSheetYConstraint.constant = 2*self.view.bounds.size.height;
                                  if (! [self respondsToSelector:@selector(presentationController)]) {
                                      // iOS 7 only
                                      [self.view removeConstraint:self.contentsViewWidthConstraint];
                                      NSLayoutConstraint *widthConstraint =
                                      [NSLayoutConstraint constraintWithItem:self.contentsView
                                                                   attribute:NSLayoutAttributeWidth
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeWidth
                                                                  multiplier:1
                                                                    constant:0];
                                      [self.view addConstraint:widthConstraint];
                                      self.contentsViewWidthConstraint = widthConstraint;

                                      [self.view removeConstraint:self.contentsViewHeightConstraint];
                                      NSLayoutConstraint *heightConstraint =
                                      [NSLayoutConstraint constraintWithItem:self.contentsView
                                                                   attribute:NSLayoutAttributeHeight
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self.view
                                                                   attribute:NSLayoutAttributeHeight
                                                                  multiplier:1
                                                                    constant:0];
                                      [self.view addConstraint:heightConstraint];
                                      self.contentsViewHeightConstraint = heightConstraint;
                                  }
                                  [self.view layoutIfNeeded];
                              }
                              completion:^(BOOL finished) {
                                  [self.actionSheet removeFromSuperview];
                                  self.actionSheet = nil;
                                  self.deeplink = nil;
                              }];
}

#pragma mark -

//- (void)viewWillLayoutSubviews{
//    self.contentsView.frame = CGRectMake(0, 0, self.view.frame.size.width/2, self.view.frame.size.height/2);
//    [super viewWillLayoutSubviews];
//}


-(void) renderUI
{
    if ([self.switchButton isOn]) {
        [self renderUIFull];
    } else {
        [self renderUILight];
    }
}

-(void) renderUIFull
{
    if (!self.actionSheet) {
        [self slideIn];
    }
}

-(void) renderUILight
{
    [[self.resultView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    UIView *result = (UIView*)[DLMEViewLight viewForDeeplink:self.deeplink enableLocation:self.locationEnabled];
    [result dlmeRoundCorners];
    [self.resultView addSubview:result];
    
    [self stretchToSuperView:result];
}

- (void) stretchToSuperView:(UIView*) view {
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    NSString * formatH = @"H:|[view]|";
    NSArray * constraintH = [NSLayoutConstraint constraintsWithVisualFormat:formatH options:0 metrics:nil views:bindings];
    [view.superview addConstraints:constraintH];

//    float height = view.bounds.size.height;
    NSString * formatV = [NSString stringWithFormat:@"V:|[view]|"];
    NSArray * constraintV = [NSLayoutConstraint constraintsWithVisualFormat:formatV options:0 metrics:nil views:bindings];
    [view.superview addConstraints:constraintV];
}

- (IBAction)onSwitchUI:(id)sender {
    if (!self.deeplink) {
        return;
    }
    
    [[self.resultView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    [self renderUI];
}

-(void) updateCreateButton
{
    if ([self.keywordsTextField.text length] && [[AppWordsSDK sharedInstance] isInitialized]) {
        self.createButton.alpha = 1.0;
        self.createButton.enabled = YES;
    }
    else {
        self.createButton.alpha = 0.6;
        self.createButton.enabled = NO;
    }
}

- (IBAction)onEditSearch:(id)sender {
    [self updateCreateButton];
}

@end
