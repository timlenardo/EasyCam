//
//  GalleryThumbnailView.h
//  SimpleCam
//
//  Created by Timothy Lenardo on 6/17/16.
//  Copyright © 2016 Upcast, Inc. All rights reserved.
//

@import Photos;

@protocol GalleryButtonDelegate <NSObject>
- (void)onGalleryButtonTapped;
@end

@interface GalleryThumbnailView : UIView <PHPhotoLibraryChangeObserver>

@property (nonatomic, readwrite, weak) id<GalleryButtonDelegate> galleryButtonDelegate;

@end