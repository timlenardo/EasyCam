//
//  VideoProgressRing.h
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SimpleCamConstants.h"

@interface VideoProgressRing : UIView

- (instancetype)initWithFrame:(CGRect)frame withRingWidth:(CGFloat)ringWidth withMaxLength:(CGFloat)maxLength withIncrement:(CGFloat)increment;

- (void)startAnimation;
- (void)stopAnimation;

@end