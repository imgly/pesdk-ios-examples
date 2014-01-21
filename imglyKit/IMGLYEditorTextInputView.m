//
//  IMGLYEditorTextInput.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 02.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorTextInputView.h"

@interface IMGLYEditorTextInputView() <UITextViewDelegate>

@property (nonatomic, strong) UITextView *textField;

@end

#pragma mark -

@implementation IMGLYEditorTextInputView

#pragma mark - init
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self == nil)
        return nil;
    
    [self commonInit];
    return self;
}

- (id)init {
    self = [super init];
    if (self == nil)
        return nil;

    return self;
}

- (void)commonInit {
    self.autoresizesSubviews = NO;
    self.textFont = IMGLYTextFontAvenir;
    self.fontSize = 12;
    self.clipsToBounds = YES;
    [self configureTextField];
}

- (void)configureTextField {
    _textField = [[UITextView alloc] init];
    _textField.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
    _textField.textColor = [UIColor whiteColor];
    _textField.delegate = self;
    _textField.editable = YES;
    _textField.clipsToBounds = NO;
    _textField.scrollEnabled = NO;
    self.textField.frame = CGRectMake(0,0,100,30);
    [self addSubview:_textField];
}

#pragma mark - layout
- (void)layoutSubviews {
    [super layoutSubviews];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    self.isInEditMode = YES;
    return YES;
}

- (void)textViewDidChange:(UITextView *)textView {
    [self updateFrame];
}

- (void)dismissKeyboard {
    self.isInEditMode = NO;
    [self.textField endEditing:YES];
}

- (void)setTextColor:(UIColor *)color {
    self.textField.textColor = color;
}

- (UIColor *)textColor {
    return self.textField.textColor;
}

- (void)setFontSize:(CGFloat) fontSize {
    _fontSize = fontSize;
    [self updateFont];
    [self updateFrame];
}

- (void)setTextFont:(IMGLYTextFont)textFont {
    _textFont = textFont;
    [self updateFont];
    [self updateFrame];
}

- (void)updateFont {
    self.textField.font = [self fontWithType:self.textFont andSize:self.fontSize];
}

- (void)updateFrame {
    CGRect frame = self.textField.frame;
    // here we calculate the new size. Note that we add some extra space at the right.
    // if we dont the new frame would cause line breaks
    frame.size.width = [self.textField.text sizeWithFont:self.textField.font
                                       constrainedToSize:self.frame.size
                                           lineBreakMode:NSLineBreakByWordWrapping].width + [@"___" sizeWithFont:self.textField.font].width;
    frame.size.height = [self.textField.text sizeWithFont:self.textField.font
                                       constrainedToSize:self.frame.size
                                           lineBreakMode:NSLineBreakByWordWrapping].height + [@"___" sizeWithFont:self.textField.font].height;
    self.textField.frame = frame;
    frame = self.frame;
    frame.size = self.textField.frame.size;
    self.frame = frame;
}

- (CGRect)renderedTextFrameForFontSize:(CGFloat)size {
    UIFont *font = [self fontWithType:self.textFont andSize:size];
    CGSize newSize =  [self.textField.text sizeWithFont:font
                                      constrainedToSize:self.frame.size
                                          lineBreakMode:NSLineBreakByWordWrapping];
    CGRect newFrame = self.frame;
    newFrame.size = newSize;
    return newFrame;
}

- (CGRect)renderedTextFrame {
    CGRect rect = [self renderedTextFrameForFontSize:self.fontSize];
    CGSize size = rect.size;
    if(size.width < 20) {
        size.width = 20;
    }
    if(size.height < 20) {
        size.height = 20;
    }
    rect.size = size;
    return rect;
}

- (UIFont *)fontWithType:(IMGLYTextFont)fontType andSize:(CGFloat)size {
    UIFont *font = nil;
    switch (fontType) {
        case IMGLYTextFontHelvetica:
            font = [UIFont fontWithName:@"Helvetica" size:size];
            break;
        case IMGLYTextFontAvenir:
            font = [UIFont fontWithName:@"Avenir" size:size];
            break;
        case IMGLYTextFontTimesNewRoman:
            font = [UIFont fontWithName:@"TimesNewRomanPSMT" size:size];
            break;
    }
    return font;
}

- (UIFont *)currentUIFontWithScale:(CGFloat)scale; {
    return [self fontWithType:self.textFont andSize:self.fontSize * scale];
}

- (NSString *)text {
    return self.textField.text;
}

- (CGPoint)textOffset {
    CGPoint position = self.textField.frame.origin;
    
    position.x += self.textField.contentInset.left;
    position.y += self.textField.contentInset.top;
    return position;
}

@end
