//
//  CardsView.m
//  AppWordsSDKExample
//
//  Created by Maya Milusheva on 7/16/15.
//  Copyright (c) 2015 Deeplink.me. All rights reserved.
//

#import "CardsView.h"

#import <AppWordsSDK/DLMEView.h>
#import "UIView+DLME_IB_CATEGORY.h"

@interface CardsView()
@property (nonatomic, strong) NSMutableArray<DLMELink*> *deeplinks;
@property (nonatomic, strong) NSMutableDictionary<NSIndexPath*, DLMEView*> *deepviews;
@end

@implementation CardsView

-(id) initWithCoder:(NSCoder *)aDecoder
{
    if (self = [super initWithCoder:aDecoder]) {
        _deeplinks = [NSMutableArray array];
        _deepviews = [NSMutableDictionary dictionary];
    }
    
    return self;
}

-(void) awakeFromNib
{
    [super awakeFromNib];
    UINib *nib = [UINib nibWithNibName:@"CardsCell" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forCellWithReuseIdentifier:@"CardsCell"];
    nib = [UINib nibWithNibName:@"CardsHeader" bundle:[NSBundle mainBundle]];
    [self.collectionView registerNib:nib forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"CardsHeader"];
}

-(void) didMoveToSuperview
{
    [super didMoveToSuperview];
    if (!self.superview) {
        return;
    }
}

-(void) addDeeplink:(DLMELink*) deeplink
{
    [self.deeplinks addObject:deeplink];
    [self.collectionView reloadData];
}

- (void)layoutSubviews
{
    CGFloat topInset = MAX(self.bounds.size.height - self.collectionView.collectionViewLayout.collectionViewContentSize.height, self.bounds.size.height/2);
    if (topInset != self.collectionView.contentInset.top) {
        [self.collectionView.collectionViewLayout invalidateLayout];
        self.collectionView.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
    }

    [super layoutSubviews];

//    __weak UICollectionView *weakView = self.collectionView;
//
//    dispatch_async(dispatch_get_main_queue(), ^{
//        UICollectionView *view = weakView;
//        if (view) {
//            CGFloat topInset = MAX(self.bounds.size.height - self.collectionView.collectionViewLayout.collectionViewContentSize.height, self.bounds.size.height/2);
//            if (topInset != self.collectionView.contentInset.top) {
//                [view.collectionViewLayout invalidateLayout];
//                view.contentInset = UIEdgeInsetsMake(topInset, 0, 0, 0);
//            }
//        }
//    });
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.deeplinks.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"CardsCell" forIndexPath:indexPath];
    
    if (cell.subviews.count > 0) {
        [cell.subviews.firstObject removeFromSuperview];
    }
    
    DLMEView *view = self.deepviews[indexPath];
    if (view == nil) {
        view = [DLMEView viewForDeeplink:[self.deeplinks objectAtIndex:indexPath.row]];
        self.deepviews[indexPath] = view;
    }
    [view dlmeRoundCorners];
    [cell addSubview:view];
    [cell dlmeAddShadow];
    
    view.translatesAutoresizingMaskIntoConstraints = NO;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(view);
    
    NSString *formatTemplate = @"%@:|[view]|";
    for (NSString * axis in @[@"H",@"V"]) {
        NSString * format = [NSString stringWithFormat:formatTemplate,axis];
        NSArray * constraints = [NSLayoutConstraint constraintsWithVisualFormat:format options:0 metrics:nil views:bindings];
        [cell addConstraints:constraints];
    }
    
    return cell;
}

// The view that is returned must be retrieved from a call to -dequeueReusableSupplementaryViewOfKind:withReuseIdentifier:forIndexPath:
- (UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    if ([kind isEqualToString:UICollectionElementKindSectionHeader]) {
        UICollectionReusableView *titleView = [collectionView dequeueReusableSupplementaryViewOfKind:kind withReuseIdentifier:@"CardsHeader" forIndexPath:indexPath];
        //titleView has been sized, but not its subviews ...
        [titleView layoutSubviews];
        UIView *title = titleView.subviews.firstObject;
        [title dlmeRoundCorners];
        [title dlmeAddShadow];
        return titleView;
    }
    return nil;
}

#pragma mark – UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return CGSizeMake(self.collectionView.bounds.size.width - 10, 135);
}

@end
