//
//  SimpleCameraViewController.h
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <AssetsLibrary/AssetsLibrary.h> //<<Can delete if not storing videos to the photo library.  Delete the assetslibrary framework too requires this)
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import <Foundation/Foundation.h>
#import <ImageIO/ImageIO.h>

#define CAPTURE_FRAMES_PER_SECOND 20

#import "FlashButtonView.h"
#import "FlipButtonView.h"
#import "GalleryThumbnailView.h"
#import "ShutterButtonView.h"
#import "FocusIndicatorView.h"

// Implement these for whatever view is presenting the QuickCam
@protocol SimpleCameraDelegate <NSObject>

- (void) onCameraDismissed;
- (void) onPhotoCaptured:(UIImage*)image;
- (void) onVideoCaptured:(NSURL*)url;
- (void) onGallerySelected;

@end


@interface SimpleCameraViewController : UIViewController <AVCaptureFileOutputRecordingDelegate, ShutterButtonDelegate, FlipButtonDelegate, FlashButtonDelegate, GalleryButtonDelegate>
{
    BOOL isRecording;
    
    AVCaptureSession *captureSession;
    AVCaptureMovieFileOutput *movieFileOutput;
    AVCaptureStillImageOutput *stillImageOutput;
    AVCaptureDeviceInput *videoInputDevice;
}

@property (nonatomic, readwrite, weak) id<SimpleCameraDelegate> simpleCameraDelegate;
@property (retain) AVCaptureVideoPreviewLayer *PreviewLayer;

@end
