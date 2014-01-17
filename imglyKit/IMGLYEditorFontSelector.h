//
//  IMGLYFontSelector.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 19.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol IMGLYEditorFontSelectorDelegate;

@interface IMGLYEditorFontSelector : UIScrollView

@property (nonatomic, weak) id<IMGLYEditorFontSelectorDelegate> selectorDelegate;
@property (nonatomic, strong) UIColor *textColor;

@end

@protocol IMGLYEditorFontSelectorDelegate <NSObject>

- (void)selectedFontWithName:(NSString *)fontName;

@end
