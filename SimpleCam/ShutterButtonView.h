//
//  ShutterButtonView.h
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// Recording max length
#define LONG_PRESS_MAX_LENGTH_SEC 15
#define LONG_PRESS_MIN_LENGTH_SEC 0.5
#define LONG_PRESS_START_THRESHOLD_SEC 0.25 // This is how long we wait before starting recording

// Starting the animation
#define LONG_PRESS_START_ANIMATION_DURATION_SEC 0.25

// Video Recording animation

// Appearance parameters
#define SHUTTER_BUTTON_DEFAULT_WIDTH 80
#define SHUTTER_BUTTON_INTERNAL_WIDTH 50
#define SHUTTER_BUTTON_EXPANDED_WIDTH 100
#define SHUTTER_BUTTON_PROGRESS_WIDTH 10


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