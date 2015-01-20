//
//  IMGLYFilter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 25.06.13.
//  Copyright (c) 2013 9elements GmbH. All rights reserved.
//

#import "IMGLYFilter.h"

#import "IMGLY669Filter.h"
#import "IMGLY8BitFIlter.h"
#import "IMGLY9EK1Filter.h"
#import "IMGLY9EK2Filter.h"
#import "IMGLY9EK6Filter.h"
#import "IMGLY9EKDynamicFilter.h"
#import "IMGLYA15Filter.h"
#import "IMGLYBWFilter.h"
#import "IMGLYBWHardFilter.h"
#import "IMGLYBWSoftFilter.h"
#import "IMGLYBoxTiltShiftFilter.h"
#import "IMGLYBrightnessFilter.h"
#import "IMGLYContrastFilter.h"
#import "IMGLYEarlyBirdFilter.h"
#import "IMGLYFoodFilter.h"
#import "IMGLYGaussFilter.h"
#import "IMGLYGlamFilter.h"
#import "IMGLYGobblinFilter.h"
#import "IMGLYHippieFilter.h"
#import "IMGLYLomoFilter.h"
#import "IMGLYLordFilter.h"
#import "IMGLYMellowFilter.h"
#import "IMGLYNoiseFilter.h"
#import "IMGLYNoneFilter.h"
#import "IMGLYOrientationFilter.h"
#import "IMGLYPaleFilter.h"
#import "IMGLYPolaFilter.h"
#import "IMGLYRadialTiltShiftFilter.h"
#import "IMGLYSaturationFilter.h"
#import "IMGLYSemiRedFilter.h"
#import "IMGLYSinCityFilter.h"
#import "IMGLYSketchFilter.h"
#import "IMGLYSunnyFilter.h"
#import "IMGLYTejasFilter.h"
#import "IMGLYFixieFilter.h"
#import "IMGLYFridgeFilter.h"
#import "IMGLYFrontFilter.h"
#import "IMGLYLeninFilter.h"
#import "IMGLYQuoziFilter.h"
#import "IMGLYOrchridFilter.h"
#import "IMGLYChestNutFilter.h"
#import "IMGLYBreezeFilter.h"
#import "IMGLYX400Filter.h"


#import <NEGPUImage/GPUImage.h>

@implementation IMGLYFilter

static NSMutableDictionary *__registeredFilterClasses;

+ (void)initialize {
    if (self != [IMGLYFilter class])
        return;

    [self registerFilterClasses];
}

+ (void)registerFilterClasses {
    __registeredFilterClasses = [NSMutableDictionary dictionary];
    __registeredFilterClasses[@(IMGLYFilterTypeNone)] = NSStringFromClass([IMGLYNoneFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeLord)] = NSStringFromClass([IMGLYLordFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypePale)] = NSStringFromClass([IMGLYPaleFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeHippie)] = NSStringFromClass([IMGLYHippieFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeSemiRed)] = NSStringFromClass([IMGLYSemiRedFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeTejas)] = NSStringFromClass([IMGLYTejasFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeSunny)] = NSStringFromClass([IMGLYSunnyFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeMellow)] = NSStringFromClass([IMGLYMellowFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeA15)] = NSStringFromClass([IMGLYA15Filter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeFood)] = NSStringFromClass([IMGLYFoodFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeLomo)] = NSStringFromClass([IMGLYLomoFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeBW)] = NSStringFromClass([IMGLYBWFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeBWHard)] = NSStringFromClass([IMGLYBWHardFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeBWSoft)] = NSStringFromClass([IMGLYBWSoftFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeSinCity)] = NSStringFromClass([IMGLYSinCityFilter  class]);
    __registeredFilterClasses[@(IMGLYFilterTypeSketch)] = NSStringFromClass([IMGLYSketchFilter class]);
    __registeredFilterClasses[@(IMGLYFilterType8Bit)] = NSStringFromClass([IMGLY8BitFIlter class]);
    __registeredFilterClasses[@(IMGLYFilterType669)] = NSStringFromClass([IMGLY669Filter class]);
    __registeredFilterClasses[@(IMGLYFilterTypePale)] = NSStringFromClass([IMGLYPaleFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeGlam)] = NSStringFromClass([IMGLYGlamFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeEarlyBird)] = NSStringFromClass([IMGLYEarlyBirdFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeGobblin)] = NSStringFromClass([IMGLYGobblinFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeBrightness)] = NSStringFromClass([IMGLYBrightnessFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeContrast)] = NSStringFromClass([IMGLYContrastFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeSaturation)] = NSStringFromClass([IMGLYSaturationFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeBoxTiltShift)] = NSStringFromClass([IMGLYBoxTiltShiftFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeRadialTiltShift)] = NSStringFromClass([IMGLYRadialTiltShiftFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeGauss)] = NSStringFromClass([IMGLYGaussFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeOrientation)] = NSStringFromClass([IMGLYOrientationFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypePola)] = NSStringFromClass([IMGLYPolaFilter class]);
    __registeredFilterClasses[@(IMGLYFilterType9EK1)] = NSStringFromClass([IMGLY9EK1Filter class]);
    __registeredFilterClasses[@(IMGLYFilterType9EK2)] = NSStringFromClass([IMGLY9EK2Filter class]);
    __registeredFilterClasses[@(IMGLYFilterType9EK6)] = NSStringFromClass([IMGLY9EK6Filter class]);
    __registeredFilterClasses[@(IMGLYFilterType9EKDynamic)] = NSStringFromClass([IMGLY9EKDynamicFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeNoise)] = NSStringFromClass([IMGLYNoiseFilter class]);
   __registeredFilterClasses[@(IMGLYFilterTypeFridge)] = NSStringFromClass([IMGLYFridgeFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeBreeze)] = NSStringFromClass([IMGLYBreezeFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeChestnut)] = NSStringFromClass([IMGLYChestNutFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeFront)] = NSStringFromClass([IMGLYFrontFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeFixie)] = NSStringFromClass([IMGLYFixieFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeLenin)] = NSStringFromClass([IMGLYLeninFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeOchrid)] = NSStringFromClass([IMGLYOrchridFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeQouzi)] = NSStringFromClass([IMGLYQuoziFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeX400)] = NSStringFromClass([IMGLYX400Filter class]);
}

+ (GPUImageOutput <GPUImageInput> *)filterWithType:(IMGLYFilterType)filterType {
    NSString *className = __registeredFilterClasses[@(filterType)];
    Class class = NSClassFromString(className);
    NSAssert(class != nil, @"No class for filter type %ld", (long)filterType);
    return [[class alloc] init];
}

@end
