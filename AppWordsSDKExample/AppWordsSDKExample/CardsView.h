//
//  CardsView.h
//  AppWordsSDKExample
//
//  Created by Maya Milusheva on 7/16/15.
//  Copyright (c) 2015 Deeplink.me. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DLMELink;

@interface CardsView : UIView<UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

-(void) addDeeplink:(DLMELink*) deeplink;

@end
