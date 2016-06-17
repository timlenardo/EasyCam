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
    UIImageView *_thumbnailView;
    
    NSString *_lastFilename;
    CGRect _insetImageSize;
    
}
@end

@implementation GalleryThumbnailView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.clipsToBounds = YES;
    self.layer.backgroundColor = [UIColor blackColor].CGColor;
    self.layer.cornerRadius = 8;
    self.layer.borderColor = [UIColor whiteColor].CGColor;
    self.layer.borderWidth = 2.0f;
    
    _thumbnailView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
    _thumbnailView.clipsToBounds = YES;
    [self addSubview:_thumbnailView];
    
    [self fetchLastImage:NO];
    [[PHPhotoLibrary sharedPhotoLibrary] registerChangeObserver:self];
    
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
        [[PHImageManager defaultManager] requestImageForAsset:lastAsset
                                                   targetSize:self.bounds.size
                                                  contentMode:PHImageContentModeAspectFill
                                                      options:PHImageRequestOptionsVersionCurrent
                                                resultHandler:^(UIImage *result, NSDictionary *info) {
                                                    dispatch_async(dispatch_get_main_queue(), ^{
                                                        if (shouldAnimate) {
                                                            [self animateNewMedia:result];
                                                        } else {
                                                            [_thumbnailView setImage:result];
                                                        }
                                                    });
                                                }];
    }
}

- (void)animateNewMedia:(UIImage*)result {
    [UIView animateWithDuration:0.25
                     animations:^{
                         _thumbnailView.alpha = 0;
                         _thumbnailView.transform = CGAffineTransformScale(_thumbnailView.transform, 0.1, 0.1);
                     }
                     completion:^(BOOL finished) {
                         
                         _thumbnailView.alpha = 1;
                         [_thumbnailView setImage:result];
                         [UIView animateWithDuration:0.25
                                          animations:^{
                                              _thumbnailView.transform = CGAffineTransformScale(_thumbnailView.transform, 10.0, 10.0);
                                          }];
                     }];
}

- (void)photoLibraryDidChange:(PHChange *)changeInstance {
    // Call might come on any background queue. Re-dispatch to the main queue to handle it.
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"Gallery did change!");
        [self fetchLastImage:YES];
    });
}

@end
