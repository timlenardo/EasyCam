//
//  ShutterButtonView.m
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ShutterButtonView.h"
#import "VideoProgressRing.h"

@interface ShutterButtonView() {
    UIControl *_shutterButton;
    UIControl *_shutterButtonInternal;
    VideoProgressRing *_videoProgressRing;
    BOOL _isPressed;
    BOOL _isRecording;
}
@end

@implementation ShutterButtonView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    CGFloat centerX = frame.size.width / 2;
    CGFloat centerY = frame.size.height / 2;
    
    CGFloat startX = centerX - SHUTTER_BUTTON_DEFAULT_WIDTH / 2;
    CGFloat startY = centerY - SHUTTER_BUTTON_DEFAULT_WIDTH / 2;
    
    _shutterButton = [[UIControl alloc] initWithFrame:CGRectMake(startX, startY, SHUTTER_BUTTON_DEFAULT_WIDTH, SHUTTER_BUTTON_DEFAULT_WIDTH)];
    _shutterButton.alpha = 0.5;
    _shutterButton.layer.cornerRadius = SHUTTER_BUTTON_DEFAULT_WIDTH / 2;
    _shutterButton.backgroundColor = [UIColor whiteColor];
    
    // Antialiasing the edges, makes it look a bit cleaner
    _shutterButton.layer.borderWidth = 3;
    _shutterButton.layer.borderColor = [UIColor clearColor].CGColor;
    _shutterButton.layer.shouldRasterize = YES;
    _shutterButton.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    [self addSubview:_shutterButton];
    
    CGFloat startXInternal = centerX - SHUTTER_BUTTON_INTERNAL_WIDTH / 2;
    CGFloat startYInternal = centerY - SHUTTER_BUTTON_INTERNAL_WIDTH / 2;
    
    _shutterButtonInternal = [[UIControl alloc] initWithFrame:CGRectMake(startXInternal, startYInternal, SHUTTER_BUTTON_INTERNAL_WIDTH, SHUTTER_BUTTON_INTERNAL_WIDTH)];
    _shutterButtonInternal.alpha = 1.0;
    _shutterButtonInternal.layer.cornerRadius = SHUTTER_BUTTON_INTERNAL_WIDTH / 2;
    _shutterButtonInternal.backgroundColor = [UIColor whiteColor];
    
    // Antialiasing the edges, makes it look a bit cleaner
    _shutterButtonInternal.layer.borderWidth = 3;
    _shutterButtonInternal.layer.borderColor = [UIColor clearColor].CGColor;
    _shutterButtonInternal.layer.shouldRasterize = YES;
    _shutterButtonInternal.layer.rasterizationScale = [[UIScreen mainScreen] scale];
    
    [self addSubview:_shutterButtonInternal];
    
    // Initialize progress ring with same frame as the outer shutterButton
    _videoProgressRing = [[VideoProgressRing alloc] initWithFrame:CGRectMake(startX, startY, SHUTTER_BUTTON_DEFAULT_WIDTH, SHUTTER_BUTTON_DEFAULT_WIDTH)
                                                    withRingWidth:SHUTTER_BUTTON_PROGRESS_WIDTH
                                                    withMaxLength:LONG_PRESS_MAX_LENGTH_SEC
                                                    withIncrement:-1.0];
    
    [_shutterButton addTarget:self action:@selector(shutterButtonTouchDown) forControlEvents:(UIControlEventTouchDown)];
    [_shutterButton addTarget:self action:@selector(shutterButtonTouchUp) forControlEvents:(UIControlEventTouchUpInside|UIControlEventTouchUpOutside)];
    [_shutterButtonInternal addTarget:self action:@selector(shutterButtonTouchDown) forControlEvents:(UIControlEventTouchDown)];
    [_shutterButtonInternal addTarget:self action:@selector(shutterButtonTouchUp) forControlEvents:(UIControlEventTouchUpInside|UIControlEventTouchUpOutside)];
    
    return self;
}


- (void)shutterButtonTouchDown {
    _isPressed = YES;
    [self performSelector:@selector(maybeStartRecording) withObject:self afterDelay:LONG_PRESS_START_THRESHOLD_SEC];
}

- (void)shutterButtonTouchUp {
    _isPressed = NO;
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(maybeStartRecording) object:self];
    
    if (_isRecording) {
        [_shutterButtonDelegate onShutterButtonLongPressUp];
        [self stopRecordingAnimation];
    } else {
        [_shutterButtonDelegate onShutterButtonSingleTapped];
    }
    _isDisabled = YES;
}

- (void)maybeStartRecording {
    if (_isPressed) {
        [_shutterButtonDelegate onShutterButtonLongPressDown];
        [self startRecordingAnimation];
    }
}

#pragma RecordingAnimation
// You can customize this to whatever you want!
- (void)startRecordingAnimation {
    _isRecording = YES;
    
    _shutterButtonInternal.backgroundColor = [UIColor redColor];
    // Add the ring animation, and start it up!
    [self addSubview:_videoProgressRing];
    [_videoProgressRing startAnimation];
    
    CGFloat expansionFactor = (CGFloat)SHUTTER_BUTTON_EXPANDED_WIDTH / SHUTTER_BUTTON_DEFAULT_WIDTH;
    [UIView animateWithDuration:LONG_PRESS_START_ANIMATION_DURATION_SEC
                     animations:^(void) {
                         _shutterButton.transform = CGAffineTransformScale(_shutterButton.transform, expansionFactor, expansionFactor);
                         _videoProgressRing.transform = CGAffineTransformScale(_videoProgressRing.transform, expansionFactor, expansionFactor);
                     }
                     completion:^(BOOL finished){
                         if (finished) {
                             
                         }
                     }];
}

- (void)stopRecordingAnimation {
    _isRecording = NO;
    
    _shutterButtonInternal.backgroundColor = [UIColor whiteColor];
    [_videoProgressRing stopAnimation];
    
    CGFloat contractionFactor = (CGFloat)SHUTTER_BUTTON_DEFAULT_WIDTH / SHUTTER_BUTTON_EXPANDED_WIDTH;
    [UIView animateWithDuration:LONG_PRESS_START_ANIMATION_DURATION_SEC
                     animations:^(void) {
                         _shutterButton.transform = CGAffineTransformScale(_shutterButton.transform, contractionFactor, contractionFactor);
                         _videoProgressRing.transform = CGAffineTransformScale(_videoProgressRing.transform, contractionFactor, contractionFactor);
                     }
                     completion:^(BOOL finished) {
                         if (finished) {
                             [_videoProgressRing removeFromSuperview];
                         }
                     }];
}

@end
