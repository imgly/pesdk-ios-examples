//
//  IMGLYEditorTextViewController.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 29.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorTextViewController.h"

#import "IMGLYEditorTextMenu.h"
#import "IMGLYPhotoProcessor_Private.h"
#import "IMGLYProcessingJob.h"
#import "IMGLYTextOperation.h"
#import "IMGLYEditorFontSelector.h"
#import "IMGLYDeviceDetector.h"

#import "UINavigationController+IMGLYAdditions.h"

static const CGFloat kMenuViewHeight = 95.0;
static const CGFloat kCropNavbarHeight = 44.0;
static const CGFloat kMinimumFontSize = 12.0;
static const CGFloat kTextMarginLeft = 8.0;
static const CGFloat kKeyBoardHeight = 432.0;
static const CGFloat kTextInputHeight = 40.0;
static const CGFloat kFontSizeInTextInput = 20.0;
static const CGFloat kTextLabelInitialMargin = 40.0;

@interface IMGLYEditorTextViewController() <IMGLYEditorTextMenuColorButtonDelegate, UIGestureRecognizerDelegate, IMGLYEditorFontSelectorDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic, strong) IMGLYEditorTextMenu *menu;
@property (nonatomic, assign) CGPoint panOffset;
@property (nonatomic, strong) IMGLYEditorFontSelector *fontSelector;
@property (nonatomic, strong) NSString *fontName;
@property (nonatomic, strong) UILabel *textLabel;
@property (nonatomic, strong) UITextField *textInput;
@property (nonatomic, assign) CGSize keyboardSize;
@property (nonatomic, assign) CGFloat currentTextSize;
@property (nonatomic, assign) CGFloat fontSizeAtPinchBegin;
@property (nonatomic, assign) CGFloat distanceAtPinchBegin;
@property (nonatomic, assign) BOOL beganTwoFingerPitch;
@property (nonatomic, assign) CGFloat maximumFontSize;
@property (nonatomic, strong) UIView *textLabelClipView;

@end

#pragma mark -

@implementation IMGLYEditorTextViewController

#pragma mark - init
- (id)init {
    self = [super init];
    if (self == nil)
        return nil;
    [self commonInit];
    return self;
}

- (id)initWithImageProvider:(id<IMGLYEditorImageProvider>)imageProvider {
    self = [super initWithImageProvider:imageProvider];
    if (self == nil)
        return nil;
    [self commonInit];
    return self;
}

#pragma mark - GUI configuration
- (void)commonInit {
    self.title = @"Text";
    _textColor = [UIColor whiteColor];
    [self hideDoneButton];
    [self disableZoomOnTap];
    [self configureMenu];
    [self configureTextInput];
    [self configureTextLabelClipView];
    [self configureTextLabel];
    [self configureFontSelector];
    [self registerForKeyboardNotifications];
    [self addPanGestureRecognizerToTextInput];
    [self addPinchGestureRecognizerToTextLabel];
}

- (void)configureTextLabelClipView {
    _textLabelClipView = [[UIView alloc] init];
    _textLabelClipView.frame = CGRectMake(0, 0, 100, 100);
    _textLabelClipView.clipsToBounds = YES;
    [self.view addSubview: _textLabelClipView];
   
}

- (void)configureTextLabel {
    _textLabel = [[UILabel alloc] init];
    _textLabel.alpha = 0.0;
    _textLabel.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
    _textLabel.textColor = self.textColor;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.clipsToBounds = YES;
    [_textLabelClipView addSubview:_textLabel];
    //[self.view insertSubview:_textLabel belowSubview:self.bottomImageView];
}

- (void)configureFontSelector {
    _fontSelector = [[IMGLYEditorFontSelector alloc] init];
    _fontSelector.selectorDelegate = self;
    [self.view addSubview:_fontSelector];
}

- (void)configureMenu {
    _menu = [[IMGLYEditorTextMenu alloc] initWithFrame:CGRectZero];
    _menu.menuDelegate = self;
    [self.view addSubview:_menu];
}

- (void)configureTextInput {
    _textInput = [[UITextField alloc] init];
    _textInput.delegate = self;
    _textInput.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.5];
    _textInput.text = @"";
    _textInput.alpha = 0.0;
    _textInput.textColor = self.textColor;
    _textInput.clipsToBounds = NO;
    _textInput.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    [_textInput setReturnKeyType:UIReturnKeyDone];
    [self.view addSubview:_textInput];
}

#pragma mark - gesture recognizer setup

- (void)addPinchGestureRecognizerToTextLabel {
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGesture:)];
    [self.view addGestureRecognizer:pinchGestureRecognizer];
}

- (void)addPanGestureRecognizerToTextInput {
    _textLabel.userInteractionEnabled = YES;
    UIPanGestureRecognizer *panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleTextInputPan:)];
    panGestureRecognizer.delegate = self;
    [_textLabel addGestureRecognizer:panGestureRecognizer];
}

#pragma mark - notification setup / handling
- (void)registerForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
}

- (void)unregisterForKeyboardNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardDidShowNotification object:nil];
}

- (void)keyboardWasShown:(NSNotification*)aNotification {
    NSDictionary* info = [aNotification userInfo];
    self.keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [self layoutTextInput];
    [self showTextInput];
}

#pragma mark - layout
- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    [self layoutMenu];
    [self layoutFontSelector];
    [self layoutTextInput];
    self.textLabelClipView.frame = CGRectMake(self.leftPreviewBound,
                                              self.topPreviewBound,
                                              self.rightPreviewBound -  self.leftPreviewBound,
                                              self.bottomPreviewBound - self.topPreviewBound);
}

- (void)layoutFontSelector {
    if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7.0")) {
        self.fontSelector.frame = CGRectMake(self.view.frame.origin.x,
                0.0,
                self.view.frame.size.width,
                self.view.frame.size.height -  kMenuViewHeight);
    }
    else {
        self.fontSelector.frame = CGRectMake(self.view.frame.origin.x,
                self.view.frame.origin.y,
                self.view.frame.size.width,
                self.view.frame.size.height -  kMenuViewHeight);
    }
}

- (void)layoutMenu {
    self.menu.frame = CGRectMake(0,
                                 self.view.frame.size.height - kMenuViewHeight ,
                                 self.view.frame.size.width,
                                 kMenuViewHeight);
}

- (void)layoutTextInput {
    self.textInput.frame = CGRectMake(0.0,
                                      self.view.frame.size.height - self.keyboardSize.height - kTextInputHeight,
                                      self.view.frame.size.width,
                                      kTextInputHeight);
}

#pragma mark - button handler
- (void)doneButtonTouchedUpInside:(UIButton *)button {
    if (self.textLabel.alpha < 1.0) {
        return;
    }
    [[self navigationController] imgly_fadePopViewController];
    IMGLYProcessingJob *job = [self prosessingJob];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] setInputImage:self.inputImage];
    [[IMGLYPhotoProcessor sharedPhotoProcessor] performProcessingJob:job];
    UIImage *image = [[IMGLYPhotoProcessor sharedPhotoProcessor] outputImage];
    self.completionHandler(IMGLYEditorViewControllerResultDone, image, job);
}

#pragma mark - gesture handling

/*
 Well this is some hardcore thinking going on.
 In this method, we calculate the distance we moved, 
 check if the rendred text fits on the screen,
 and if not we correct the actual view rect acording to the differences
 */
- (void)handleTextInputPan:(UIPanGestureRecognizer *)recognizer {
    CGPoint location = [recognizer locationInView:self.textLabelClipView];
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        self.panOffset = [recognizer locationInView:self.textLabel];
    }
    CGRect frame = self.textLabel.frame;
    frame.origin.x = location.x - self.panOffset.x;
    frame.origin.y = location.y - self.panOffset.y;
    self.textLabel.frame = frame;
}

- (void)handlePinchGesture:(UIPinchGestureRecognizer *) recognizer {
    if (recognizer.state == UIGestureRecognizerStateBegan) {
        self.fontSizeAtPinchBegin = self.currentTextSize;
        self.beganTwoFingerPitch = NO;
    }
    if(recognizer.numberOfTouches > 1) {
        CGPoint point1 = [recognizer locationOfTouch:0 inView:self.view];
        CGPoint point2 = [recognizer locationOfTouch:1 inView:self.view];
        if (!self.beganTwoFingerPitch) {
            self.beganTwoFingerPitch = YES;
            self.distanceAtPinchBegin = [self calculateNewFontSizeBasedOnDistanceBetween:point1 and:point2];
        }
        CGFloat distance = [self calculateNewFontSizeBasedOnDistanceBetween:point1 and:point2];
        self.currentTextSize = self.fontSizeAtPinchBegin - (self.distanceAtPinchBegin - distance) / 2.0;
        self.currentTextSize = MAX(kMinimumFontSize, self.currentTextSize);
        self.currentTextSize = MIN(self.maximumFontSize, self.currentTextSize);
        self.textLabel.font = [UIFont fontWithName:self.fontName size:self.currentTextSize];
        [self updateTextLabelFrameForCurrentFont];
    }
}

- (CGFloat)calculateNewFontSizeBasedOnDistanceBetween:(CGPoint)point1 and:(CGPoint)point2 {
    CGFloat diffX = point1.x - point2.x;
    CGFloat diffY = point1.y - point2.y;
    CGFloat distance = sqrtf(diffX * diffX + diffY  * diffY);
    return distance;
}

#pragma mark - tools
- (CGPoint)transformedTextPosition {
    CGPoint position = self.textLabel.frame.origin;
    position.x = position.x / self.scaledImageSize.width;
    position.y = position.y / self.scaledImageSize.height;
    return position;
}

- (IMGLYProcessingJob *)prosessingJob {
    IMGLYProcessingJob *job = [[IMGLYProcessingJob alloc] init];
    IMGLYTextOperation *operation = [[IMGLYTextOperation alloc] init];
    operation.text = [self.textLabel text];
    //operation.font = [UIFont fontWithName:self.fontName size:floorf(self.currentTextSize * scaleFactor) ];
    operation.fontHeightScaleFactor = self.currentTextSize / self.scaledImageSize.height;
    operation.fontName = self.fontName;
    operation.position = [self transformedTextPosition];
    operation.color = self.textLabel.textColor;
    [job addOperation:(IMGLYOperation *)operation];
    return job;
}


#pragma mark - cleanup
- (void)viewWillDisappear:(BOOL)animated {
    [self unregisterForKeyboardNotifications];
}

#pragma mark - textview handling
- (BOOL)textFieldShouldBeginEditing:(UITextView *)textView {
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextView *)textView {
    [self.textInput resignFirstResponder];
    [self hideTextInput];
    self.textLabel.text = self.textInput.text;
    [self setInitialTextLabelSize];
    [self showTextLabel];
    [self showDoneButton];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)dismissKeyboard {
    [self.textInput endEditing:YES];
}

#pragma mark - text input handling
- (void)showTextInput {
    [UIView animateWithDuration:0.2 animations:^{
        self.textInput.alpha = 1.0;
    }];
}

- (void)hideTextInput {
    [UIView animateWithDuration:0.2 animations:^{
        self.textInput.alpha = 0.0;
    }];
}

#pragma mark - text label handling
- (void)showTextLabel {
    [UIView animateWithDuration:0.2 animations:^{
        self.textLabel.alpha = 1.0;
    }];
}

- (void)calculateInitialFontSize {
    self.currentTextSize = 1.0;
    CGSize size = CGSizeZero;
    do {
        self.currentTextSize += 1.0;
        self.textLabel.font = [UIFont fontWithName:self.fontName size:self.currentTextSize];
        size = [self.textLabel.text sizeWithFont:self.textLabel.font];
    }
    while (size.width < (self.view.frame.size.width - kTextLabelInitialMargin));
}

- (void)calculateMaximumFontSize {
    CGSize size = CGSizeZero;
    self.maximumFontSize = self.currentTextSize;
    do {
        self.maximumFontSize += 1.0;
        self.textLabel.font = [UIFont fontWithName:self.fontName size:self.maximumFontSize];
        size = [self.textLabel.text sizeWithFont:self.textLabel.font];
    }
    while (size.width < (self.view.frame.size.width));    
}

- (void)setInitialTextLabelSize {
    [self calculateInitialFontSize];
    [self calculateMaximumFontSize];
    
    self.textLabel.font = [UIFont fontWithName:self.fontName size:self.currentTextSize];
    CGSize size = [self.textLabel.text sizeWithFont:self.textLabel.font];
    self.textLabel.frame = CGRectMake(kTextLabelInitialMargin / 2.0 - self.textLabelClipView.frame.origin.x,
                                      (self.view.frame.size.height - kMenuViewHeight) / 2.0 - size.height / 2.0,
                                      size.width,
                                      size.height);
}

- (void)updateTextLabelFrameForCurrentFont {
    // resize and keep the text centred
    CGRect frame = self.textLabel.frame;
    frame.size = [self.textLabel.text sizeWithFont:self.textLabel.font];
    CGFloat diffX = self.textLabel.frame.size.width - frame.size.width;
    CGFloat diffY = self.textLabel.frame.size.height - frame.size.height;
    frame.origin.x += (diffX / 2.0);
    frame.origin.y += (diffY / 2.0);
    self.textLabel.frame = frame;
}

#pragma mark - font selector handling 
- (void)selectedFontWithName:(NSString *)fontName {
    self.fontName = fontName;
    [UIView animateWithDuration:0.3 animations:^{
        self.fontSelector.alpha = 0.0;
    } completion:^(BOOL finished) {
        self.textInput.font = [UIFont fontWithName:self.fontName size:kFontSizeInTextInput];
        [self.textInput becomeFirstResponder];
        [self.fontSelector removeFromSuperview];
    }];
}

#pragma mark - color selection handling 
- (void)selectedColor:(UIColor *)color {
    self.textColor = color;
    self.textLabel.textColor = color;
    self.fontSelector.textColor = color;
    self.textInput.textColor = color;
}

@end
