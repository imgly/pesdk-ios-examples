//
//  IMGLYMainMenuEntryMetaData.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 01.08.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IMGLYMainMenuEntryMetaData : NSObject

@property (nonatomic, strong) NSString *text;
@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) Class viewControllerClass;

- (instancetype)initWithText:(NSString *)text image:(UIImage *)image viewControllerClass:(Class)viewControllerClass;

@end
