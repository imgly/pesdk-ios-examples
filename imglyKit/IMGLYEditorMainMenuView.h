//
//  IMGLYEditorMainMenuView.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 25.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol IMGLYEditorImageProvider;
@protocol IMGLYEditorMainMenuDelegate;

@interface IMGLYEditorMainMenuView : UIScrollView

@property (nonatomic, weak) id<IMGLYEditorMainMenuDelegate> menuDelegate;

- (instancetype)initWithFrame:(CGRect)frame imageProvider:(id<IMGLYEditorImageProvider>)imageProvider;
- (void)setMagicActive;
- (void)setMagicInActive;

@end

#pragma mark -

@protocol IMGLYEditorMainMenuDelegate <NSObject>

- (void)mainMenuButtonTouchedUpInsideWithViewControllerClass:(Class)viewControllerClass;

@end
