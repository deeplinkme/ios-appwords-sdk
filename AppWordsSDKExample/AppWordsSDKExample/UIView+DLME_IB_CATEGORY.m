//
//  UIView+DLME_IB_CATEGORY.m
//  AppWordsSDKExample
//
//  Created by David Jacobson on 03/11/2015.
//  Copyright © 2015 Deeplink.me. All rights reserved.
//

#import "UIView+DLME_IB_CATEGORY.h"

@implementation UIView (DLME_IB_CATEGORY)

-(void)dlmeAddShadow {
    self.layer.cornerRadius = 2;
    self.layer.shadowColor = [UIColor blackColor].CGColor;
    self.layer.shadowRadius = 2.0f;
    self.layer.shadowOpacity = 0.4f;
    CGRect bounds = self.layer.bounds;
    CGRect shadowBounds = CGRectMake(bounds.origin.x-1,
                                     bounds.origin.y+5,
                                     bounds.size.width+2,
                                     bounds.size.height);
    self.layer.shadowPath = [UIBezierPath bezierPathWithRect:shadowBounds].CGPath;

    self.layer.masksToBounds = NO;
}

-(void)dlmeRoundCorners {
    self.layer.cornerRadius = 2;
    if (self.layer.shadowPath != nil) {
        self.layer.masksToBounds = YES;
    }
}

@end
