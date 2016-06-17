//
//  GalleryThumbnailView.m
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GalleryThumbnailView.h"

@interface GalleryThumbnailView() {
    UIButton *_thumbnailView;
    
    NSString *_lastFilename;
    CGRect _insetImageSize;
    
    int _newMediaCount;
    UIView *_badgeView;
    UILabel *_badgeLabel;
}
@end

@implementation GalleryThumbnailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    
    UIView *thumbnailContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0 + kGalleryBadgeWidth / 4, frame.size.width - kGalleryBadgeWidth / 4, frame.size.height - kGalleryBadgeWidth / 4)];
    thumbnailContainer.clipsToBounds = YES;
    thumbnailContainer.layer.backgroundColor = [UIColor blackColor].CGColor;
    thumbnailContainer.layer.cornerRadius = kGalleryButtonRadius;
    thumbnailContainer.layer.borderColor = [UIColor whiteColor].CGColor;
    thumbnailContainer.layer.borderWidth = kGalleryButtonBorderWidth;
    [self addSubview:thumbnailContainer];
    
    _thumbnailView = [[UIButton alloc] initWithFrame:thumbnailContainer.frame];
    _thumbnailView.clipsToBounds = YES;
    [thumbnailContainer addSubview:_thumbnailView];
    
    _newMediaCount = -1;
    CGFloat badgeWidth = kGalleryBadgeWidth;
    CGRect badgeFrame = CGRectMake(frame.size.width - badgeWidth, 0, badgeWidth, badgeWidth);
    CGRect badgeLabelFrame = CGRectMake(badgeFrame.origin.x + kBadgeLabelInset, badgeFrame.origin.y + kBadgeLabelInset, badgeWidth - 2 * kBadgeLabelInset, badgeWidth - 2 *kBadgeLabelInset);
    _badgeView = [[UIView alloc] initWithFrame:badgeFrame];
    _badgeLabel = [[UILabel alloc] initWithFrame:badgeLabelFrame];
    
    [self fetchLastImage:NO];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
    [self addTarget:self action:@selector(galleryButtonTapped) forControlEvents:(UIControlEventTouchUpInside)];
    [_thumbnailView addTarget:self action:@selector(galleryButtonTapped) forControlEvents:(UIControlEventTouchUpInside)];
    
    return self;
}

- (void)fetchLastImage:(BOOL)shouldAnimate {
    PHFetchOptions *fetchOptions = [[PHFetchOptions alloc] init];
    fetchOptions.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    // TODO find a way to fetch all photo/video in a single request
    PHFetchResult *fetchPhotoResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeImage options:fetchOptions];
    PHFetchResult *fetchVideoResult = [PHAsset fetchAssetsWithMediaType:PHAssetMediaTypeVideo options:fetchOptions];
    PHAsset *lastPhotoAsset = [fetchPhotoResult lastObject];
    PHAsset *lastVideoAsset = [fetchVideoResult lastObject];
    PHAsset *lastAsset;
    if ([lastPhotoAsset valueForKey:@"creationDate"] > [lastVideoAsset valueForKey:@"creationDate"]) {
        lastAsset = lastPhotoAsset;
    } else {
        lastAsset = lastVideoAsset;
    }
    
    NSString *filename = [lastAsset valueForKey:@"filename"];
    if (![filename isEqualToString:_lastFilename]) {
        _lastFilename = filename;
        _newMediaCount = _newMediaCount + 1;
        [_badgeLabel setText:[NSString stringWithFormat:@"%d", _newMediaCount]];
        if (_newMediaCount == 1) {
            [self addSubview:_badgeView];
            [self addSubview:_badgeLabel];
            _badgeView.clipsToBounds = YES;
            _badgeView.backgroundColor = kGalleryBadgeColor;
            _badgeView.layer.cornerRadius = kGalleryBadgeWidth / 2;
            _badgeLabel.textAlignment = NSTextAlignmentCenter;
            _badgeLabel.adjustsFontSizeToFitWidth = YES;
            _badgeLabel.textColor = [UIColor whiteColor];
            
        }
        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                   targetSize:self.bounds.size
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:PHImageRequestOptionsVersionCurrent
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        if (shouldAnimate) {
                                                            [self animateNewMedia:result];
                                                        } else {
                                                            [_thumbnailView setBackgroundImage:result forState:UIControlStateNormal];
                                                        }
                                                    });
                                                }];
    }
}

- (void)animateNewMedia:(UIImage*)result {
    // Write your own gallery animation here!
    [UIView animateWithDuration:kAnimationDuration
                     animations:^{
                         _thumbnailView.alpha = 0;
                         _thumbnailView.transform = CGAffineTransformScale(_thumbnailView.transform, 0.1, 0.1);
                     }
                     completion:^(BOOL finished) {
                         
                         _thumbnailView.alpha = 1;
                        [_thumbnailView setBackgroundImage:result forState:UIControlStateNormal];
                         [UIView animateWithDuration:kAnimationDuration
                                          animations:^{
                                              _thumbnailView.transform = CGAffineTransformScale(_thumbnailView.transform, 10.0, 10.0);
                                          }];
                     }];
    
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self fetchLastImage:YES];
    });
}

- (void)galleryButtonTapped {
    [_galleryButtonDelegate onGalleryButtonTapped];
}

@end
