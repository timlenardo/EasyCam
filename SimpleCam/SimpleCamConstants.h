//
//  SimpleCamConfig.h
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

// What else do we need here? Let me know on Github. 


// ### GENERIC CONFIG STUFF ###

#define kShouldAutoSave YES
#define kEnableDismissButton YES

#define kMaxVideoLengthSec 15
#define kAnimationDuration 0.25
#define kLongPressMinimumDuration 0.25



// ### SHUTTER BUTTON APPEARANCE ###

#define kShutterButtonOuterWidth 80
#define kShutterButtonOuterColor [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:0.5]
#define kShutterButtonInnerWidth 50
#define kShutterButtonInnerColor [UIColor whiteColor]

#define kShutterButtonExpandedWidth 100
#define kShutterButtonRecordingColor 10
#define kShutterButtonRecordingProgressWidth 5



// ### GALLERY BUTTON CONFIGURATION ###

#define kGalleryWidth 45
#define kGalleryButtonRadius 8
#define kGalleryButtonBorderWidth 2.0f
#define kGalleryButtonBorderColor [UIColor whiteColor]

#define kGalleryBadgeWidth 20
#define kGalleryBadgeColor [UIColor colorWithRed:90.0/255.0 green:145.0/255.0 blue:205.0/255.0 alpha:1.0]
#define kBadgeLabelInset 1



// ### FOCUS INDICATOR CONFIGURATION ###

#define kFocusIndicatorWidth 80
#define kLockWidth 20
#define kLockPaddingBottom 5
#define kIndicatorLoopingPeriod 400



// ### ICONS CONFIGURATION ###

#define kIconWidth 35
#define kDismissImage @"x.png"
#define kFlashAutoImage @"flash.png"
#define kFlashOnImage @"flash_on.png"
#define kFlashOffImage @"flash_off.png"
#define kFlipImage = @"flip.png"
#define kLockImage = @"lock.png"