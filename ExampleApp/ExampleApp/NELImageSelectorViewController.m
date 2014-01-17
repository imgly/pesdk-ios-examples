//
//  NELImageSelectorViewController.m
//  ExampleApp
//
//  Created by Carsten Przyluczky on 18.09.13.
//  Copyright (c) 2013 9elements Gmbh. All rights reserved.
//

#import "NELImageSelectorViewController.h"
#import <imglyKit/IMGLYKit.h>

@interface NELImageSelectorViewController()

@property (nonatomic, strong)UIButton *goldenImageButton;
@property (nonatomic, strong)UIButton *alexImageButton;
@property (nonatomic, strong)UIButton *trainImageButton;
@property (nonatomic, strong)UIButton *surferImageButton;
@property (nonatomic, strong)UIButton *bobaImageButton;
@property (nonatomic, strong)NSArray *availableFilterList;

@end

@implementation NELImageSelectorViewController

- (instancetype)initWithAvailableFilterList:(NSArray *)list {
    self = [super init];
    if (self) {
        _availableFilterList = list;
        [self commonInit];
    }

    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
    self.title = @"Choose an image";
    self.view.backgroundColor = [UIColor colorWithWhite:0.15 alpha:1.0];
    [self configureButtons];
}

- (void)configureButtons {
    _goldenImageButton  = [self buttonAtX:0   Y:0 imageName:@"golden"];
    _alexImageButton    = [self buttonAtX:160 Y:0 imageName:@"alexplatz"];
    _surferImageButton  = [self buttonAtX:160 Y:160 imageName:@"surfer"];
    _trainImageButton   = [self buttonAtX:0   Y:320 imageName:@"train"];
    _bobaImageButton    = [self buttonAtX:0   Y:160 imageName:@"example.jpg"];
}


- (UIButton*)buttonAtX:(float)x Y:(float)y imageName:(NSString*)imageName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    UIImage *image = [UIImage imageNamed:imageName];
    [button setImage:image forState:UIControlStateNormal];
    [button addTarget:self
                action:@selector(filterButtonTouchedUpInside:)
                 forControlEvents:UIControlEventTouchUpInside];
    button.frame = CGRectMake(x, y, 150,150);
    [self.view addSubview:button];
    return button;
}

- (void)filterButtonTouchedUpInside:(UIButton *)button {
    IMGLYEditorViewController *editorViewController = [[IMGLYEditorViewController alloc] init];
    editorViewController.availableFilterList = [self availableFilterList];
    editorViewController.inputImage = button.imageView.image;
    [self.navigationController pushViewController:editorViewController animated:YES];
}

@end
