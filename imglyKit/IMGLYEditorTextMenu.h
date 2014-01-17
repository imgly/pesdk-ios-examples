//
//  IMGLYEditorTextMenu.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 29.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMGLYEditorTextMenuColorButtonDelegate;

@interface IMGLYEditorTextMenu : UIScrollView

@property (nonatomic, weak) id<IMGLYEditorTextMenuColorButtonDelegate> menuDelegate;

@end

@protocol IMGLYEditorTextMenuColorButtonDelegate <NSObject>

- (void)selectedColor:(UIColor *)color;

@end
