//
//  IMGLYFontSelector.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 19.09.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYEditorFontSelector.h"

#import "IMGLYDefines.h"
#import "NSBundle+IMGLYAdditions.h"

#import <CoreText/CoreText.h>

const CGFloat kDistanceBetweenButtons = 60;
const CGFloat kFontSize = 28.0;

static BOOL fontsRegistred = NO;

@interface IMGLYEditorFontSelector()

@property (nonatomic, strong) NSArray *fontNames;

@end

@implementation IMGLYEditorFontSelector

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
    self.selectorDelegate = nil;
    self.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.4];
    if (!fontsRegistred) {
        [self importFontsWithExtension:@"ttf"];
        [self importFontsWithExtension:@"otf"];
        fontsRegistred = YES;
    }
    [self configureFontName];
    [self configureFontButtons];
}

- (void) importFontsWithExtension:(NSString *)extension {
    for (NSString *fontPath in [[NSBundle imgly_frameworkBundle] pathsForResourcesOfType:extension inDirectory:nil]) {
        NSData *inData = [NSData dataWithContentsOfFile:fontPath];
        CFErrorRef error;
        CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)inData);
        CGFontRef font = CGFontCreateWithDataProvider(provider);
        if (! CTFontManagerRegisterGraphicsFont(font, &error)) {
            CFStringRef errorDescription = CFErrorCopyDescription(error);
            DLog(@"Failed to load font: %@", errorDescription);
            CFRelease(errorDescription);
        }
        CFRelease(font);
        CFRelease(provider);
    }
}

- (void)configureFontName {
    _fontNames = @[@"AmericanTypewriter",
                   @"Avenir-Heavy",
                   @"ChalkboardSE-Regular",
                   @"ArialMT",
                   @"BanglaSangamMN",
                   @"Liberator",
                   @"Muncie",
                   @"Abraham Lincoln",
                   @"Airship 27",
                   @"Arvil",
                   @"Bender",
                   @"Blanch",
                   @"Cubano",
                   @"Franchise",
                   @"Geared Slab",
                   @"Governor",
                   @"Haymaker",
                   @"Homestead",
                   @"Maven Pro Light",
                   @"Mensch",
                   @"Sullivan",
                   @"Tommaso",
                   @"Valencia",
                   @"Vevey"];
}

- (void)configureFontButtons {
    for (NSString *fontName in _fontNames) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setTitle:fontName forState:UIControlStateNormal];
        button.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [button.titleLabel setFont:[UIFont fontWithName:fontName  size:kFontSize]];
        [button addTarget:self
                   action:@selector(filterButtonTouchedUpInside:)
         forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
}

- (void) layoutSubviews {
    NSInteger index = 0;
    for (id view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            [button setFrame:CGRectMake(0,
                                        index * kDistanceBetweenButtons,
                                        self.frame.size.width,
                                        kDistanceBetweenButtons)];
            index++;
        }
    }
    self.contentSize = CGSizeMake(self.frame.size.width - 1.0, index * kDistanceBetweenButtons);
}

- (void)filterButtonTouchedUpInside:(UIButton *)button {
    if(self.selectorDelegate != nil) {
        [self.selectorDelegate selectedFontWithName:button.titleLabel.text];
    }
}

- (void)setTextColor:(UIColor *)textColor {
    _textColor = textColor;
    for (id view in self.subviews) {
        if ([view isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)view;
            button.titleLabel.textColor = textColor;
        }
    }
}
@end
