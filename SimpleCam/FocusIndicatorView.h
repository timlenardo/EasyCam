//
//  FocusIndicatorView.h
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleCamConstants.h"

@interface FocusIndicatorView : UIView

- (void)showAtPoint:(CGPoint)location;
- (void)lock;
- (void)finishAnimation;

@end