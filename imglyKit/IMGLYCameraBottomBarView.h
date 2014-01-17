//
//  IMGLYCameraBottomBarView.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 12.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IMGLYCameraBottomBarCommandDelegate;
@protocol IMGLYCameraImageProvider;

@interface IMGLYCameraBottomBarView : UIView

@property (nonatomic, weak) id<IMGLYCameraBottomBarCommandDelegate> delegate;

- (instancetype)initWithYPosition:(CGFloat)yPosition;
- (instancetype)initWithYPosition:(CGFloat)yPosition imageProvider:(id<IMGLYCameraImageProvider>)imageProvider;

- (void)setArrowDirectionUp;
- (void)setArrowDirectionDown;
- (void)setAlphaForAllViews:(CGFloat)alpha;
- (void)enableAllButtons;
- (void)disableAllButtons;
- (void)rotateForPortraitOrientation;
- (void)rotateForLandscapeLeftOrientation;
- (void)rotateForLandscapeRightOrientation;
- (CGFloat)backgroundAlpha;

@end

#pragma mark -

@protocol IMGLYCameraBottomBarCommandDelegate <NSObject>

- (void)takePhoto;
- (void)selectFromCameraRoll;
- (void)toggleFilterSelector;

@end
