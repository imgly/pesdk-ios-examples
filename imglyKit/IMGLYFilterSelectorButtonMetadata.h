//
//  IMGLYFilterSelectorButtonMetadata.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 14.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFilter.h"

#import <UIKit/UIKit.h>

@interface IMGLYFilterSelectorButtonMetadata : NSObject

@property (nonatomic, assign) IMGLYFilterType filterType;
@property (nonatomic, copy) NSString *previewFileName;
@property (nonatomic, strong) UIImage *staticPreviewImage;
@property (nonatomic, strong) UIImage *dynamicPreviewImage;
@property (nonatomic, copy) NSString *filterName;

@end
