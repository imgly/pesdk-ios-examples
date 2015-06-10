//
//  LUTToNSDataConverter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 29/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#import "LUTToNSDataConverter.h"
#if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
#import <UIKit/UIKit.h>
#elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#import <AppKit/AppKit.h>
#import <imglyKit/imglyKit-Swift.h>
#endif
#import <Accelerate/Accelerate.h>

static const int kDimension = 64;
static NSData *identityLUT;

@implementation LUTToNSDataConverter

+ (nullable NSData *)colorCubeDataFromLUTNamed:(nonnull NSString *)name interpolatedWithIdentityLUTNamed:(nonnull NSString *)identityName withIntensity:(float)intensity cacheIdentityLUT:(BOOL)shouldCache {
    if (intensity < 0 || intensity > 1) {
        return nil;
    }
    
    NSData *interpolatedLUT;
    
    @autoreleasepool {
        NSData *lut = [self colorCubeDataFromLUT:name];
        if (!lut) {
            return nil;
        }
        
        NSData *identity;
        if (!shouldCache) {
            identity = [self colorCubeDataFromLUT:identityName];
        } else {
            if (identityLUT != nil) {
                identity = identityLUT;
            } else {
                identityLUT = [self colorCubeDataFromLUT:identityName];
                identity = identityLUT;
            }
        }
        
        if (!identity) {
            return nil;
        }
        
        if (lut.length != identity.length) {
            return nil;
        }
        
        NSUInteger size = lut.length;
        
        const float *lutData = (const float *)lut.bytes;
        const float *identityData = (const float *)identity.bytes;
        
        float *data = malloc(size);
        vDSP_vsbsm(lutData, 1, identityData, 1, &intensity, data, 1, size / sizeof(float));
        vDSP_vadd(data, 1, identityData, 1, data, 1, size / sizeof(float));
        
        // This is basically Accelerate Framework's way of doing this:
        //        for (int i = 0; i < size / sizeof(float); i++) {
        //            data[i] = (lutData[i] - identityData[i]) * intensity + identityData[i];
        //        }
        
        interpolatedLUT = [NSData dataWithBytesNoCopy:data length:size freeWhenDone:YES];
    }
    
    return interpolatedLUT;
}

/*
 This method reads an LUT image and converts it to a cube color space representation.
 The resulting data can be used to feed an CIColorCube filter, so that the transformation
 realised by the LUT is applied with a core image standard filter
 */
+ (nullable NSData *)colorCubeDataFromLUT:(nonnull NSString *)name {
    #if defined(__IPHONE_OS_VERSION_MIN_REQUIRED)
    UIImage *image = [UIImage imageNamed:name inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    #elif defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
    NSBundle *bundle = [NSBundle bundleForClass:self.class];
    NSImage *image = [bundle imageForResource:name];
    image.name = name;
    #endif
    
    if (!image) {
        return nil;
    }
    
    NSInteger width = CGImageGetWidth(image.CGImage);
    NSInteger height = CGImageGetHeight(image.CGImage);
    NSInteger rowNum = height / kDimension;
    NSInteger columnNum = width / kDimension;
    
    if ((width % kDimension != 0) || (height % kDimension != 0) || (rowNum * columnNum != kDimension)) {
        NSLog(@"Invalid colorLUT %@",name);
        return nil;
    }
    
    float *bitmap = [self createRGBABitmapFromImage:image.CGImage];
    
    if (bitmap == NULL) {
        return nil;
    }
    
    NSInteger size = kDimension * kDimension * kDimension * sizeof(float) * 4;
    float *data = malloc(size);
    int bitmapOffset = 0;
    int z = 0;
    for (int row = 0; row <  rowNum; row++) {
        for (int y = 0; y < kDimension; y++) {
            int tmp = z;
            for (int col = 0; col < columnNum; col++) {
                NSInteger dataOffset = (z * kDimension * kDimension + y * kDimension) * 4;
                
                const float divider = 255.0;
                vDSP_vsdiv(&bitmap[bitmapOffset], 1, &divider, &data[dataOffset], 1, kDimension * 4);
                
                bitmapOffset += kDimension * 4;
                z++;
            }
            z = tmp;
        }
        z += columnNum;
    }
    
    free(bitmap);
    
    return [NSData dataWithBytesNoCopy:data length:size freeWhenDone:YES];
}

+ (float *)createRGBABitmapFromImage:(CGImageRef)image {
    CGContextRef context = NULL;
    CGColorSpaceRef colorSpace;
    unsigned char *bitmap;
    NSInteger bitmapSize;
    NSInteger bytesPerRow;
    
    size_t width = CGImageGetWidth(image);
    size_t height = CGImageGetHeight(image);
    
    bytesPerRow   = (width * 4);
    bitmapSize     = (bytesPerRow * height);
    
    bitmap = malloc( bitmapSize );
    if (bitmap == NULL) {
        return NULL;
    }
    
    colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        free(bitmap);
        return NULL;
    }
    
    context = CGBitmapContextCreate (bitmap,
                                     width,
                                     height,
                                     8,
                                     bytesPerRow,
                                     colorSpace,
                                     (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    CGColorSpaceRelease( colorSpace );
    
    if (context == NULL) {
        free (bitmap);
        return NULL;
    }
    
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), image);
    CGContextRelease(context);
    
    float *convertedBitmap = malloc(bitmapSize * sizeof(float));
    vDSP_vfltu8(bitmap, 1, convertedBitmap, 1, bitmapSize);
    free(bitmap);
    
    return convertedBitmap;
}

@end
