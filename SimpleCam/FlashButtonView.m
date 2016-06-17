//
//  FlashButtonView.m
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>

#import "FlashButtonView.h"

@interface FlashButtonView() {
    
}
@end

@implementation FlashButtonView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    [self setBackgroundImage:[UIImage imageNamed:@"flash.png"] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(flashButtonTapped) forControlEvents:(UIControlEventTouchDown)];
    return self;
}

- (void)cameraFlipped {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25]; // Set how long your animation goes for
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.transform = CGAffineTransformRotate(self.transform, 3.141593); // if angle is in radians
    [UIView commitAnimations];
}

- (void)flashButtonTapped {
    [_flashButtonDelegate onFlashButtonTapped];
}

- (void) flashModeUpdated:(NSInteger)flashMode {
    if (flashMode == AVCaptureFlashModeOff) {
        [self setBackgroundImage:[UIImage imageNamed:@"flash_off.png"] forState:UIControlStateNormal];
    } else if (flashMode == AVCaptureFlashModeOn) {
        [self setBackgroundImage:[UIImage imageNamed:@"flash_on.png"] forState:UIControlStateNormal];
    } else if (flashMode == AVCaptureFlashModeAuto) {
        [self setBackgroundImage:[UIImage imageNamed:@"flash.png"] forState:UIControlStateNormal];
    }
}

@end
