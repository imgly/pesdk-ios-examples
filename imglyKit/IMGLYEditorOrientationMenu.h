//
//  IMGLYEditorOrientationMenu.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 21.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMGLYEditorOrientationMenuDelegate;
@protocol IMGLYEditorImageProvider;

@interface IMGLYEditorOrientationMenu : UIView

@property (nonatomic, weak) id<IMGLYEditorOrientationMenuDelegate> menuDelegate;

- (id)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYEditorImageProvider>)imageProvider;

@end

@protocol IMGLYEditorOrientationMenuDelegate <NSObject>

- (void)rotateLeftTouchedUpInside;
- (void)rotateRightTouchedUpInside;
- (void)flipVerticalTouchedUpInside;
- (void)flipHorizontalTouchedUpInside;

@end
