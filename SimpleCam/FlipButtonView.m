//
//  FlipButtonView.m
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "FlipButtonView.h"

@interface FlipButtonView() {
    
}
@end

@implementation FlipButtonView

- (instancetype) initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    [self setBackgroundImage:[UIImage imageNamed:@"flip.png"] forState:UIControlStateNormal];
    [self addTarget:self action:@selector(flipImageTapped) forControlEvents:(UIControlEventTouchDown)];
    
    return self;
}

- (void)cameraFlipped {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.25]; // Set how long your animation goes for
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    self.transform = CGAffineTransformRotate(self.transform, 3.141593); // if angle is in radians
    [UIView commitAnimations];
}

- (void)flipImageTapped {
    [_flipButtonDelegate onFlipButtonTapped];
}

@end