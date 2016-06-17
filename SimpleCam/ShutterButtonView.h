//
//  ShutterButtonView.h
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "SimpleCamConstants.h"

@protocol ShutterButtonDelegate <NSObject>
- (void) onShutterButtonSingleTapped; // Generally used to take photo
- (void) onShutterButtonLongPressDown; // Generally used to take video
- (void) onShutterButtonLongPressUp;
@end

@interface ShutterButtonView : UIButton

@property (nonatomic, readwrite, weak) id<ShutterButtonDelegate> shutterButtonDelegate;
@property BOOL isDisabled;

- (instancetype) initWithFrame:(CGRect)frame;

@end