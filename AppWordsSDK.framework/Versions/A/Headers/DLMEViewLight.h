//
//  AppWordsResultView.h
//  AppWordsSDK
//
//  Created by Maya Milusheva on 7/3/15.
//  Copyright (c) 2015 Deeplink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppWordsSDK.h"

@interface DLMEViewLight : UIView

+(DLMEViewLight*) viewForDeeplink:(DLMELink*) deeplink enableLocation:(BOOL) enableLocation;

@end
