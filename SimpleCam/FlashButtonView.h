//
//  FlashButtonView.h
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FlashButtonDelegate <NSObject>
- (void)onFlashButtonTapped;
@end

@interface FlashButtonView : UIButton

@property (nonatomic, readwrite, weak) id<FlashButtonDelegate> flashButtonDelegate;

- (void) flashModeUpdated:(NSInteger)flashMode;

@end