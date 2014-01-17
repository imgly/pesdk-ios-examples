//
//  IMGLYFilter.h
//  imglyKit
//
//  Created by Carsten Przyluczky on 25.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, IMGLYFilterType) {
    IMGLYFilterTypeNone,
    IMGLYFilterTypeLord,
    IMGLYFilterTypePale,
    IMGLYFilterTypeHippie,
    IMGLYFilterTypeSemiRed,
    IMGLYFilterTypeTejas,
    IMGLYFilterTypeSunny,
    IMGLYFilterTypeMellow,
    IMGLYFilterTypeA15,
    IMGLYFilterTypeFood,
    IMGLYFilterTypeLomo,
    IMGLYFilterTypeBW,
    IMGLYFilterTypeBWSoft,
    IMGLYFilterTypeBWHard,
    IMGLYFilterTypeSinCity,
    IMGLYFilterTypeSketch,
    IMGLYFilterType8Bit,
    IMGLYFilterType669,
    IMGLYFilterTypePola,
    IMGLYFilterTypeGlam,
    IMGLYFilterTypeEarlyBird,
    IMGLYFilterTypeGobblin,
    IMGLYFilterTypeBrightness,
    IMGLYFilterTypeContrast,
    IMGLYFilterTypeSaturation,
    IMGLYFilterTypeBoxTiltShift,
    IMGLYFilterTypeRadialTiltShift,
    IMGLYFilterTypeGauss,
    IMGLYFilterTypeOrientation,
    IMGLYFilterType9EK1,
    IMGLYFilterType9EK2,
    IMGLYFilterType9EK6,
    IMGLYFilterType9EKDynamic,
    IMGLYFilterTypeNoise,
    IMGLYFilterTypeFridge,
    IMGLYFilterTypeBreeze,
    IMGLYFilterTypeChestnut,
    IMGLYFilterTypeFront,
    IMGLYFilterTypeFixie,
    IMGLYFilterTypeLenin,
    IMGLYFilterTypeOchrid,
    IMGLYFilterTypeQouzi,
    IMGLYFilterTypeX400
 };

@class GPUImageOutput;
@protocol GPUImageInput;

@interface IMGLYFilter : NSObject

+ (GPUImageOutput <GPUImageInput> *)filterWithType:(IMGLYFilterType)filterType;

@end
