//
//  SimpleCameraViewController.m
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import "SimpleCameraViewController.h"
#import "GalleryThumbnailView.h"
#import "ShutterButtonView.h"

#import <Foundation/Foundation.h>

@interface SimpleCameraViewController() {
    
}

@property (strong, nonatomic) GalleryThumbnailView *galleryView;
@property (strong, nonatomic) FlipButtonView *flipView;
@property (strong, nonatomic) FlashButtonView *flashView;
@property (strong, nonatomic) FocusIndicatorView *focusView;
@property (strong, nonatomic) ShutterButtonView *shutterView;
@property (strong, nonatomic) UIButton *exitView;

@property AVCaptureFlashMode flashMode;
@property AVCaptureTorchMode torchMode;
@property BOOL isZooming;
@property BOOL isLongPressing;
@property CGFloat lastY;
@property CGFloat startZoom;

@end

@implementation SimpleCameraViewController

@synthesize PreviewLayer;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    captureSession = [[AVCaptureSession alloc] init];
    
    [[self view] setBackgroundColor:[UIColor blackColor]];
    // Add Video Output
    AVCaptureDevice *VideoDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    if (VideoDevice) {
        NSError *error;
        videoInputDevice = [AVCaptureDeviceInput deviceInputWithDevice:VideoDevice error:&error];
        if (!error) {
            if ([captureSession canAddInput:videoInputDevice]) {
                [captureSession addInput:videoInputDevice];
            } else {
                NSLog(@"Couldn't add video input");
            }
        } else {
            NSLog(@"Couldn't create video input");
        }
    } else {
        NSLog(@"Couldn't create video capture device");
    }
    
    // Add Audio Output
    AVCaptureDevice *audioCaptureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    NSError *error = nil;
    AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:audioCaptureDevice error:&error];
    if (audioInput) {
        [captureSession addInput:audioInput];
    }
    
    // Adding video preview layer
    [self setPreviewLayer:[[AVCaptureVideoPreviewLayer alloc] initWithSession:captureSession]];
    [[self PreviewLayer] setVideoGravity:AVLayerVideoGravityResizeAspectFill];
    
    // Add in movie file output
    NSLog(@"Adding movie file output");
    movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
    Float64 TotalSeconds = 60;
    int32_t preferredTimeScale = 30; // fps
    CMTime maxDuration = CMTimeMakeWithSeconds(TotalSeconds, preferredTimeScale);
    movieFileOutput.maxRecordedDuration = maxDuration;
    movieFileOutput.minFreeDiskSpaceLimit = 1024 * 1024;
    if ([captureSession canAddOutput:movieFileOutput]) {
        [captureSession addOutput:movieFileOutput];
    }
    
    // Add in a still image output as well
    NSLog(@"Adding still image output");
    stillImageOutput = [[AVCaptureStillImageOutput alloc] init];
    NSDictionary *outputSettings = [[NSDictionary alloc] initWithObjectsAndKeys:AVVideoCodecJPEG,AVVideoCodecKey,nil];
    [stillImageOutput setOutputSettings:outputSettings];
    if ([captureSession canAddOutput:stillImageOutput]) {
        [captureSession addOutput:stillImageOutput];
    }
    
    // Set the image quality
    [captureSession setSessionPreset:AVCaptureSessionPresetMedium];
    if ([captureSession canSetSessionPreset:AVCaptureSessionPreset640x480]) {
        [captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    }
    if ([captureSession canSetSessionPreset:AVCaptureSessionPreset1280x720]) {
        [captureSession setSessionPreset:AVCaptureSessionPreset1280x720];
    }
    
    
    // Display the preview layer
    CGRect layerRect = [[[self view] layer] bounds];
    [PreviewLayer setBounds:layerRect];
    [PreviewLayer setPosition:CGPointMake(CGRectGetMidX(layerRect),
                                          CGRectGetMidY(layerRect))];
    //We use this instead so it goes on a layer behind our UI controls (avoids us having to manually bring each control to the front):
    UIView *CameraView = [[UIView alloc] init];
    [[self view] addSubview:CameraView];
    [self.view sendSubviewToBack:CameraView];
    [[CameraView layer] addSublayer:PreviewLayer];
    
    CGFloat screenHeight = CGRectGetHeight(layerRect);
    CGFloat screenWidth = CGRectGetWidth(layerRect);
    
    // Focus Indicator
    CGFloat focusHeight = 80;
    CGFloat startXFocus = screenWidth / 2 - focusHeight / 2;
    CGFloat startYFocus = screenHeight / 2 - focusHeight / 2;
    CGRect focusFrame = CGRectMake(startXFocus, startYFocus, focusHeight, focusHeight);
    _focusView = [[FocusIndicatorView alloc] initWithFrame:focusFrame];
    [[self view] addSubview:_focusView];
    
    // Shutter Button
    CGFloat shutterHeight = screenHeight / 5;
    CGRect shutterFrame = CGRectMake(0, screenHeight - shutterHeight, screenWidth, shutterHeight);
    _shutterView = [[ShutterButtonView alloc] initWithFrame:shutterFrame];
    _shutterView.shutterButtonDelegate = self;
    [[self view] addSubview:_shutterView];
    
    // Gallery Button
    CGFloat galleryHeight = 45;
    CGFloat startXGallery = screenWidth / 4 - galleryHeight / 2 - 20; // TODO this is hardcoded, because it's dependent on the shutter button size
    CGFloat startYGallery = screenHeight - shutterHeight / 2 - galleryHeight / 2;
    CGRect galleryFrame = CGRectMake(startXGallery, startYGallery, galleryHeight, galleryHeight);
    _galleryView = [[GalleryThumbnailView alloc] initWithFrame:galleryFrame];
    _galleryView.galleryButtonDelegate = self;
    [[self view] addSubview:_galleryView];
    
    // Flip Button
    CGFloat flipHeight = 35;
    CGFloat startXFlip = screenWidth / 4 * 3 - flipHeight / 2 + 20; // TODO this is hardcoded, because it's dependent on the shutter button size
    CGFloat startYFlip = screenHeight - shutterHeight / 2 - flipHeight / 2;
    CGRect flipFrame = CGRectMake(startXFlip, startYFlip, flipHeight, flipHeight);
    _flipView = [[FlipButtonView alloc] initWithFrame:flipFrame];
    _flipView.flipButtonDelegate = self;
    [[self view] addSubview:_flipView];
    
    // Flash Button
    CGFloat flashHeight = 35;
    CGFloat startXFlash = screenWidth - flashHeight - flashHeight / 3;
    CGFloat startYFlash = flashHeight / 3;
    CGRect flashFrame = CGRectMake(startXFlash, startYFlash, flashHeight, flashHeight);
    _flashView = [[FlashButtonView alloc] initWithFrame:flashFrame];
    _flashView.flashButtonDelegate = self;
    [[self view] addSubview:_flashView];
    
    CGFloat exitHeight = 35;
    CGFloat startXExit = exitHeight / 3;
    CGFloat startYExit = exitHeight / 3;
    CGRect exitFrame = CGRectMake(startXExit, startYExit, exitHeight, exitHeight);
    _exitView = [[UIButton alloc] initWithFrame:exitFrame];
    [_exitView setBackgroundImage:[UIImage imageNamed:@"x.png"] forState:UIControlStateNormal];
    [_exitView addTarget:self action:@selector(onExitButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    [[self view] addSubview:_exitView];
    
    [captureSession startRunning];
    
    UISwipeGestureRecognizer *leftRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    leftRecognizer.direction = UISwipeGestureRecognizerDirectionLeft;
    [leftRecognizer setNumberOfTouchesRequired:1];
    leftRecognizer.cancelsTouchesInView = NO;
    [[self view] addGestureRecognizer:leftRecognizer];
    
    UISwipeGestureRecognizer *rightRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(handleSwipes:)];
    rightRecognizer.direction = UISwipeGestureRecognizerDirectionRight;
    [rightRecognizer setNumberOfTouchesRequired:1];
    rightRecognizer.cancelsTouchesInView = NO;
    [[self view] addGestureRecognizer:rightRecognizer];
    
    UITapGestureRecognizer *singleFingerTapRecognizer =
    [[UITapGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handleSingleTap:)];
    singleFingerTapRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:singleFingerTapRecognizer];
    
    UILongPressGestureRecognizer *longPressRecognizer =
    [[UILongPressGestureRecognizer alloc] initWithTarget:self
                                                  action:@selector(handleLongPress:)];
    [longPressRecognizer setMinimumPressDuration:0.25];
    longPressRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:longPressRecognizer];
    
    UIPanGestureRecognizer *panRecognizer =
    [[UIPanGestureRecognizer alloc] initWithTarget:self
                                            action:@selector(handlePan:)];
    panRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:panRecognizer];
    
    
    [videoInputDevice.device addObserver:self forKeyPath:@"adjustingExposure" options:NSKeyValueObservingOptionNew context:nil];
    [videoInputDevice.device addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
    
    _flashMode = AVCaptureFlashModeAuto;
    _torchMode = AVCaptureTorchModeAuto;
    [self maybeWriteFlashMode];
}

- (AVCaptureDevice *)CameraWithPosition:(AVCaptureDevicePosition) Position {
    NSArray *Devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *Device in Devices) {
        if ([Device position] == Position) {
            return Device;
        }
    }
    return nil;
}

- (void)toggleCameraFacing {
    if ([[AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo] count] > 1) {
        NSError *error;
        AVCaptureDeviceInput *newVideoInput;
        AVCaptureDevicePosition position = [[videoInputDevice device] position];
        
        if (position == AVCaptureDevicePositionBack) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionFront] error:&error];
        } else if (position == AVCaptureDevicePositionFront) {
            newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:[self CameraWithPosition:AVCaptureDevicePositionBack] error:&error];
        }
        
        if (newVideoInput != nil) {
            [captureSession beginConfiguration];		//We can now change the inputs and output configuration.  Use commitConfiguration to end
            [captureSession removeInput:videoInputDevice];
            if ([captureSession canAddInput:newVideoInput]) {
                [captureSession addInput:newVideoInput];
                videoInputDevice = newVideoInput;
            } else {
                [captureSession addInput:videoInputDevice];
            }
            [captureSession commitConfiguration];
            [_flipView cameraFlipped];
            [self maybeWriteFlashMode];
        }
    }
}

- (void)toggleCameraFlash {
    
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput
didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL
      fromConnections:(NSArray *)connections
                error:(NSError *)error {
    BOOL recordedSuccessfully = YES;
    if ([error code] != noErr) {
        // A problem occurred: Find out if the recording was successful.
        id value = [[error userInfo] objectForKey:AVErrorRecordingSuccessfullyFinishedKey];
        if (value) {
            recordedSuccessfully = [value boolValue];
        }
    }
    if (recordedSuccessfully) {
        [_simpleCameraDelegate onVideoCaptured:outputFileURL];
        __block PHObjectPlaceholder *placeholder;
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            PHAssetChangeRequest* createAssetRequest = [PHAssetChangeRequest creationRequestForAssetFromVideoAtFileURL:outputFileURL];
            placeholder = [createAssetRequest placeholderForCreatedAsset];
        } completionHandler:^(BOOL success, NSError *error) {
            if (success) {
                // Successfully saved to gallery
            } else {
                // Failed to save to gallery
            }
        }];
    }
}

#pragma mark - FlashButtonTapped

- (void)onFlashButtonTapped {
    if (_flashMode == AVCaptureFlashModeAuto) {
        _flashMode = AVCaptureFlashModeOn;
        _torchMode = AVCaptureTorchModeOn;
    } else if (_flashMode == AVCaptureFlashModeOn) {
        _flashMode = AVCaptureFlashModeOff;
        _torchMode = AVCaptureTorchModeOff;
    } else if (_flashMode == AVCaptureFlashModeOff) {
        _flashMode = AVCaptureFlashModeAuto;
        _torchMode = AVCaptureTorchModeAuto;
    }
    [self maybeWriteFlashMode];
    [_flashView flashModeUpdated:_flashMode];
}

- (void) maybeWriteFlashMode {
    NSError* error;
    [videoInputDevice.device lockForConfiguration:&error];
    if ([videoInputDevice.device isFlashModeSupported:_flashMode]) {
        [videoInputDevice.device setFlashMode:_flashMode];
    }
    [videoInputDevice.device unlockForConfiguration];
}

- (void)maybeWriteTorchMode {
    NSError* error;
    [videoInputDevice.device lockForConfiguration:&error];
    if ([videoInputDevice.device isTorchModeSupported:_torchMode]) {
        [videoInputDevice.device setTorchMode:_torchMode];
    }
    [videoInputDevice.device unlockForConfiguration];
}

#pragma mark - FlipButtonDelegate

- (void)onFlipButtonTapped {
    [self toggleCameraFacing];
}

#pragma mark - GalleryButtonDelegate
- (void)onGalleryButtonTapped {
    [_simpleCameraDelegate onGallerySelected];
}

#pragma mark - shutterButtonDelegate

/** Photo taking **/
- (void) onShutterButtonSingleTapped {
    if (!isRecording) {
        isRecording = YES;
        AVCaptureConnection *captureConnection = [stillImageOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoOrientationSupported]) {
            AVCaptureVideoOrientation orientation = (AVCaptureVideoOrientation)[[UIDevice currentDevice] orientation];
            [captureConnection setVideoOrientation:orientation];
        }
        [stillImageOutput captureStillImageAsynchronouslyFromConnection:captureConnection
                                                      completionHandler:^(CMSampleBufferRef imageSampleBuffer, NSError *error) {
                                                          NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageSampleBuffer];
                                                          UIImage *image = [[UIImage alloc] initWithData:imageData];
                                                          [_simpleCameraDelegate onPhotoCaptured:image];
                                                          [self saveImageToPhotoAlbum:image];
                                                      }];
    }
}

- (void)saveImageToPhotoAlbum:(UIImage *)image {
    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSaving:contextInfo:), nil);
}

- (void)image:(UIImage *)image didFinishSaving:(NSError *)error contextInfo:(void *)contextInfo {
    if (error != NULL) {
        // TODO Handle photo error
    }
    isRecording = NO;
    [self maybeWriteFlashMode];
}

/** Video recording **/
- (void) onShutterButtonLongPressDown {
    NSLog(@"start recording video!");
    if (!isRecording) {
        isRecording = YES;
        [self maybeWriteTorchMode];
        //Create temporary URL to record to
        NSString *outputPath = [[NSString alloc] initWithFormat:@"%@%@", NSTemporaryDirectory(), @"output.mov"];
        NSURL *outputURL = [[NSURL alloc] initFileURLWithPath:outputPath];
        NSFileManager *fileManager = [NSFileManager defaultManager];
        if ([fileManager fileExistsAtPath:outputPath]) {
            NSError *error;
            if ([fileManager removeItemAtPath:outputPath error:&error] == NO) {
                //Error - handle if requried
            }
        }
        
        AVCaptureConnection *captureConnection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
        if ([captureConnection isVideoOrientationSupported]) {
            AVCaptureVideoOrientation orientation = (AVCaptureVideoOrientation)[[UIDevice currentDevice] orientation];
            [captureConnection setVideoOrientation:orientation];
        }
        
        // Start recording
        [movieFileOutput startRecordingToOutputFileURL:outputURL recordingDelegate:self];
    }
}

- (void) onShutterButtonLongPressUp {
    if (isRecording) {
        isRecording = NO;
        [movieFileOutput stopRecording];
        [self maybeWriteFlashMode];
    }
}

#pragma mark - GestureRecognizers
- (void)onExitButtonTapped {
    [_simpleCameraDelegate onCameraDismissed];
}

- (void)handleSwipes:(UISwipeGestureRecognizer *)sender {
    if ((sender.direction == UISwipeGestureRecognizerDirectionLeft) || (sender.direction == UISwipeGestureRecognizerDirectionRight)) {
        [self toggleCameraFacing];
    }
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender {
    CGPoint location = [sender locationInView:self.view];
    [self autoFocusAtPoint:location];
}

- (void)handleLongPress:(UILongPressGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan){
        _isLongPressing = YES;
        CGPoint location = [sender locationInView:self.view];
        [self autoFocusAtPoint:location];
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.5);
        dispatch_after(delay, dispatch_get_main_queue(), ^(void){
            if (_isLongPressing) {
                NSError *error;
                [videoInputDevice.device lockForConfiguration:&error];
                [videoInputDevice.device setFocusMode:AVCaptureFocusModeLocked];
                [videoInputDevice.device setExposureMode:AVCaptureExposureModeLocked];
                [videoInputDevice.device unlockForConfiguration];
                [_focusView lock];
            }
        });
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        _isLongPressing = NO;
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateBegan) {
        CGPoint translation = [sender translationInView:self.view];
        // Handle horizontal swipe
        if (fabs(translation.x) > 0.0 && fabs(translation.y) == 0.0) {
            [self toggleCameraFacing];
        }
        
        // Start up vertical zoom!
        if (fabs(translation.x) == 0.0 && fabs(translation.y) > 0.0) {
            _isZooming = YES;
            _lastY = translation.y;
            _startZoom = [videoInputDevice.device videoZoomFactor];
        }
        
    } else if (sender.state == UIGestureRecognizerStateChanged) {
        
        CGRect layerRect = [[[self view] layer] bounds];
        CGFloat screenHeight = CGRectGetHeight(layerRect);
        // SWIPING UP SHOULD MAKE IT GO FROM 1 to 4 (0 to -400?)
        // SWIPING DOWN SHOULD MAKE IT GO FROM -3 to 0 (assuming you start at 4, you can go all the way back down)
        //  (0 to 400?)
        CGFloat y = [sender translationInView:self.view].y;
        
        // This should give us [0,1]+ for swipe up and [0,-1] for swipe down
        CGFloat zoomAmount = - y / (screenHeight * 3.0 / 4);
        CGFloat maxZoom = 4;
        // Swipe down
        if (zoomAmount < 0) {
            zoomAmount = zoomAmount * 3; // [0,-3]
        } else { // Swipe up
            zoomAmount = zoomAmount * 3; // [1, 4]
        }
        
        CGFloat newZoom = _startZoom + zoomAmount;
        
        
        if (newZoom > 1.0 && newZoom < maxZoom) {
            NSError *error;
            [videoInputDevice.device lockForConfiguration:&error];
            [videoInputDevice.device setVideoZoomFactor:newZoom];
            [videoInputDevice.device unlockForConfiguration];
        }
    } else if (sender.state == UIGestureRecognizerStateEnded) {
        if (_isZooming) {
            _isZooming = NO;
        }
    }
}

- (void)autoFocusAtPoint:(CGPoint)location {
    
    // Early exit for other thangs
    if (CGRectContainsPoint(_galleryView.frame, location) ||
        CGRectContainsPoint(_flipView.frame, location) ||
        CGRectContainsPoint(_flashView.frame, location) ||
        CGRectContainsPoint(_shutterView.frame, location)) {
        return;
    }
    
    [_focusView showAtPoint:location];
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    // 'setExposurePoint' expects coordinates as if the phone were in landscape mode, with the home button on the right.
    CGPoint rotated = CGPointMake(location.y, screenWidth - location.x);
    double focus_x = rotated.x / screenHeight;
    double focus_y = rotated.y / screenWidth;
    
    NSError *error;
    
    [videoInputDevice.device lockForConfiguration:&error];
    if ([videoInputDevice.device isFocusPointOfInterestSupported]) {
        [videoInputDevice.device setFocusPointOfInterest:CGPointMake(focus_x,focus_y)];
        [videoInputDevice.device setFocusMode:AVCaptureFocusModeAutoFocus];
    }
    if ([videoInputDevice.device isExposurePointOfInterestSupported]) {
        [videoInputDevice.device setExposurePointOfInterest:CGPointMake(focus_x,focus_y)];
        [videoInputDevice.device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    }
    [videoInputDevice.device unlockForConfiguration];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if ([keyPath isEqualToString:@"adjustingExposure"]) {
        // Need to do anything here? Seems like focus always takes longer.
    }
    if ([keyPath isEqualToString:@"adjustingFocus"]) {
        if (videoInputDevice.device.adjustingFocus == NO) {
            [_focusView finishAnimation];
        }
    }
}

#pragma mark - Lifecycle

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    isRecording = NO;
}

- (void)viewDidUnload {
    [super viewDidUnload];
    captureSession = nil;
    movieFileOutput = nil;
    videoInputDevice = nil;
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

// iOS 6+
- (BOOL)shouldAutorotate {
    return NO;
}

// Before iOS 6
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return NO;
}

@end