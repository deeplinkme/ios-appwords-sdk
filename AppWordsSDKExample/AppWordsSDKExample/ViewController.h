//
//  ViewController.h
//  AppWordsSDKExample
//
//  Created by Amit Attias on 2/8/15.
//  Copyright (c) 2015 Deeplink. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString *kSearchWordsURINotification;

@interface ViewController : UIViewController 
- (void)setKeywordsWithURL:(NSURL *)url;
@end

