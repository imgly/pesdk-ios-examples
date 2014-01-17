//
//  IMGLYEditorTextInput.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 02.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IMGLYTextFont) {
    IMGLYTextFontAvenir,
    IMGLYTextFontHelvetica,
    IMGLYTextFontTimesNewRoman
};

@interface IMGLYEditorTextInputView : UIView

@property (nonatomic, assign) BOOL isInEditMode;
@property (nonatomic, assign) UIColor *textColor;
@property (nonatomic, assign) CGFloat fontSize;
@property (nonatomic, assign) IMGLYTextFont textFont;

- (void)dismissKeyboard;
- (CGRect)renderedTextFrameForFontSize:(CGFloat)size;
- (CGRect)renderedTextFrame;
- (NSString *)text;
- (CGPoint)textOffset;
- (UIFont *)currentUIFontWithScale:(CGFloat)scale;

@end
