//
//  IMGLYEditorImageProvider.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 14.10.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IMGLYEditorImageProvider <NSObject>

- (UIImage *)bottomBarForEditorImage;
- (UIImage *)cropDragPointImage;
- (UIImage *)filterIcon;
- (UIImage *)orientationIcon;
- (UIImage *)focusIcon;
- (UIImage *)cropIcon;
- (UIImage *)brightnessIcon;
- (UIImage *)contrastIcon;
- (UIImage *)saturationIcon;
- (UIImage *)noiseIcon;
- (UIImage *)textIcon;
- (UIImage *)rotateLeftIcon;
- (UIImage *)rotateRightIcon;
- (UIImage *)flipHorizontalIcon;
- (UIImage *)flipVerticalIcon;
- (UIImage *)radialFocusIcon;
- (UIImage *)linearFocusIcon;
- (UIImage *)focusAnchorImage;
- (UIImage *)customRatioIcon;
- (UIImage *)oneToOneRatioIcon;
- (UIImage *)fourToThreeRatioIcon;
- (UIImage *)sixteenToNineRatioIcon;
- (UIImage *)gradientImage;
- (UIImage *)resetButtonIcon;
- (UIImage *)magicButtonIcon;
- (UIImage *)magicActiveButtonIcon;
- (UIImage *)filterActiveIcon;

@end
