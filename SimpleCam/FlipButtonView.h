//
//  FlipButtonView.h
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlipButtonDelegate <NSObject>
- (void)onFlipButtonTapped;
@end

@interface FlipButtonView : UIButton

@property (nonatomic, readwrite, weak) id<FlipButtonDelegate> flipButtonDelegate;

- (void) cameraFlipped;

@end