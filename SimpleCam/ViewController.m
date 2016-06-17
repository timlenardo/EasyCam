//
//  ViewController.m
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) UILabel* outcomeLabel;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    /** SAMPLE VIEW CONTROLLER THAT USES SIMPLECAM **/
    /** This view controller sets up a 'start camera' button that opens SimpleCam, and then handles the result **/
    
    CGRect layerRect = [[[self view] layer] bounds];
    CGFloat screenHeight = CGRectGetHeight(layerRect);
    CGFloat screenWidth = CGRectGetWidth(layerRect);
    
    CGFloat buttonHeight = 50;
    CGFloat buttonWidth = 200;
    CGRect startFrame = CGRectMake(screenWidth / 2 - buttonWidth / 2, screenHeight / 2 - buttonHeight / 2, buttonWidth, buttonHeight);
    
    UIButton *startButton = [[UIButton alloc] initWithFrame:startFrame];
    [startButton setTitle:@"Start Camera" forState:UIControlStateNormal];
    startButton.layer.cornerRadius = 8;
    startButton.layer.backgroundColor = [UIColor redColor].CGColor;
    [startButton addTarget:self action:@selector(startButtonTapped) forControlEvents:UIControlEventTouchUpInside];
    
    CGRect outcomeFrame = CGRectMake(screenWidth / 2 - buttonWidth / 2, screenHeight / 2 - buttonHeight / 2 + 100, buttonWidth, buttonHeight);
    _outcomeLabel = [[UILabel alloc] initWithFrame:outcomeFrame];
    
    [self.view addSubview:startButton];
    [self.view addSubview:_outcomeLabel];
}

# pragma mark - Actions

- (void) startButtonTapped {

    /** PRESENT SIMPLE CAM AS A MODAL VIEW CONTROLLER **/
    
    SimpleCameraViewController *simpleCam = [[SimpleCameraViewController alloc] init];
    simpleCam.simpleCameraDelegate = self;
    [self presentViewController:simpleCam animated:YES completion:nil];
}

# pragma mark - SimpleCameraDelegate

- (void) onCameraDismissed {
    
    /** HANDLE DISMISSING THE SIMPLE CAM **/
    [self dismissViewControllerAnimated:YES completion:nil];
    [_outcomeLabel setText:@"SimpleCam dismissed!"];

}

- (void) onPhotoCaptured:(UIImage*)image {
   
    /** HANDLE NEWLY CAPTURED PHOTOS **/
    /** You may want to dismiss the camera here and just handle the photo **/

}

- (void) onVideoCaptured:(NSURL*)url {

    /** HANDLE NEWLY CAPTURED PHOTOS **/
    /** You may want to dismiss the camera here and just handle the video **/

}

- (void) onGallerySelected {
    
    /** HANDLE GALLERY SELECTED **/
    /** You may want to dismiss the camera here and transition to a video view **/
    [self dismissViewControllerAnimated:YES completion:nil];
    [_outcomeLabel setText:@"Gallery selected!"];

}


@end
