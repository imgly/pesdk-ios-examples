//
//  IMGLYFilterSelectorView.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 14.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFilter.h"

#import <UIKit/UIKit.h>

@protocol IMGLYFilterSelectorViewDelegate;
@protocol IMGLYEditorImageProvider;
@protocol IMGLYCameraImageProvider;

@interface IMGLYFilterSelectorView : UIView

@property (nonatomic, weak) id<IMGLYFilterSelectorViewDelegate> delegate;

- (id)initWithFrame:(CGRect)frame previewImageSize:(CGFloat)previewImageSize;
- (void)toggleVisible;
- (void)rotateLanscapeLeftMode;
- (void)rotateLanscapeRightMode;
- (void)rotatePortraitOrientation;
- (void)rotatePortraitModeUpsideDown;
- (void)generatePreviewsForImage:(UIImage *)image;

- (void)generateStaticPreviewsForImage:(UIImage *)image;

- (void)setPreviewImagesToDefault;
- (NSString *)getSelectedFilterNameForType:(IMGLYFilterType)filterType;
- (void)hideBackground;
- (id)initWithFrame:(CGRect)frame previewImageSize:(CGFloat)previewImageSize editorImageProvider:(id<IMGLYEditorImageProvider>)imageProvider;

- (id)initWithFrame:(CGRect)frame previewImageSize:(CGFloat)previewImageSize editorImageProvider:(id <IMGLYEditorImageProvider>)imageProvider availableFilterList:(NSArray *)list;

- (id)initWithFrame:(CGRect)frame previewImageSize:(CGFloat)previewImageSize cameraImageProvider:(id<IMGLYCameraImageProvider>)imageProvider;

- (id)initWithFrame:(CGRect)frame previewImageSize:(CGFloat)previewImageSize cameraImageProvider:(id <IMGLYCameraImageProvider>)imageProvider availableFilterList:(NSArray *)list;
@end

#pragma mark -

@protocol IMGLYFilterSelectorViewDelegate <NSObject>
@optional

- (void)filterSelectorView:(IMGLYFilterSelectorView *)filterSelectorView
       didSelectFilterType:(IMGLYFilterType)filterType;

@end
