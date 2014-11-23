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
#import "IMGLY9EK6Filter.h"
#import "IMGLY9EKDynamicFilter.h"
#import "IMGLYA15Filter.h"
#import "IMGLYBWFilter.h"
#import "IMGLYBWHardFilter.h"
#import "IMGLYBWSoftFilter.h"
#import "IMGLYBrightnessFilter.h"
#import "IMGLYContrastFilter.h"
#import "IMGLYFoodFilter.h"
#import "IMGLYGaussFilter.h"
#import "IMGLYGlamFilter.h"
#import "IMGLYHippieFilter.h"
#import "IMGLYLomoFilter.h"
#import "IMGLYLordFilter.h"
#import "IMGLYMellowFilter.h"
#import "IMGLYNoneFilter.h"
#import "IMGLYPaleFilter.h"
#import "IMGLYPolaFilter.h"
#import "IMGLYSaturationFilter.h"
#import "IMGLYSketchFilter.h"
#import "IMGLYSunnyFilter.h"
#import "IMGLYTejasFilter.h"
#import "IMGLYFixieFilter.h"
#import "IMGLYFridgeFilter.h"
#import "IMGLYFrontFilter.h"
#import "IMGLYChestNutFilter.h"


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
    __registeredFilterClasses[@(IMGLYFilterTypeTejas)] = NSStringFromClass([IMGLYTejasFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeSunny)] = NSStringFromClass([IMGLYSunnyFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeMellow)] = NSStringFromClass([IMGLYMellowFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeA15)] = NSStringFromClass([IMGLYA15Filter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeFood)] = NSStringFromClass([IMGLYFoodFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeLomo)] = NSStringFromClass([IMGLYLomoFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeBW)] = NSStringFromClass([IMGLYBWFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeBWHard)] = NSStringFromClass([IMGLYBWHardFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeBWSoft)] = NSStringFromClass([IMGLYBWSoftFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeSketch)] = NSStringFromClass([IMGLYSketchFilter class]);
    __registeredFilterClasses[@(IMGLYFilterType8Bit)] = NSStringFromClass([IMGLY8BitFIlter class]);
    __registeredFilterClasses[@(IMGLYFilterType669)] = NSStringFromClass([IMGLY669Filter class]);
    __registeredFilterClasses[@(IMGLYFilterTypePale)] = NSStringFromClass([IMGLYPaleFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeGlam)] = NSStringFromClass([IMGLYGlamFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeBrightness)] = NSStringFromClass([IMGLYBrightnessFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeContrast)] = NSStringFromClass([IMGLYContrastFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeSaturation)] = NSStringFromClass([IMGLYSaturationFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeGauss)] = NSStringFromClass([IMGLYGaussFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypePola)] = NSStringFromClass([IMGLYPolaFilter class]);
    __registeredFilterClasses[@(IMGLYFilterType9EK1)] = NSStringFromClass([IMGLY9EK1Filter class]);
    __registeredFilterClasses[@(IMGLYFilterType9EK6)] = NSStringFromClass([IMGLY9EK6Filter class]);
    __registeredFilterClasses[@(IMGLYFilterType9EKDynamic)] = NSStringFromClass([IMGLY9EKDynamicFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeFridge)] = NSStringFromClass([IMGLYFridgeFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeChestnut)] = NSStringFromClass([IMGLYChestNutFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeFront)] = NSStringFromClass([IMGLYFrontFilter class]);
    __registeredFilterClasses[@(IMGLYFilterTypeFixie)] = NSStringFromClass([IMGLYFixieFilter class]);
}

+ (GPUImageOutput <GPUImageInput> *)filterWithType:(IMGLYFilterType)filterType {
    NSString *className = __registeredFilterClasses[@(filterType)];
    if(className == nil) {
        NSLog(@"");
    }
    Class class = NSClassFromString(className);
    NSAssert(class != nil, @"No class for filter type %d", filterType);
    return [[class alloc] init];
}

@end
