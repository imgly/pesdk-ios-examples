//
//  LUTToNSDataConverter.m
//  imglyKit
//
//  Created by Carsten Przyluczky on 29/01/15.
//  Copyright (c) 2015 9elements GmbH. All rights reserved.
//

#import "LUTToNSDataConverter.h"
#import <UIKit/UIKit.h>

static const int kDimension = 64;

@implementation LUTToNSDataConverter

/*
 This method reads an LUT image and converts it to a cube color space representation.
 The resulting data can be used to feed an CIColorCube filter, so that the transformation
 realised by the LUT is applied with a core image standard filter
 */
- (NSData*)colorCubeDataFromLUT:(NSString *)name {
    UIImage *image = [UIImage imageNamed:name inBundle:[NSBundle bundleForClass:self.class] compatibleWithTraitCollection:nil];
    NSInteger width = CGImageGetWidth(image.CGImage);
    NSInteger height = CGImageGetHeight(image.CGImage);
    NSInteger rowNum = height / kDimension;
    NSInteger columnNum = width / kDimension;
    
    if ((width % kDimension != 0) || (height % kDimension != 0) || (rowNum * columnNum != kDimension)) {
        NSLog(@"Invalid colorLUT %@",name);
        return nil;
    }
    
    unsigned char *bitmap = [self createRGBABitmapFromImage:image.CGImage];
    
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
                for (int x = 0; x < kDimension; x++) {
                    float r = (unsigned int)bitmap[bitmapOffset];
                    float g = (unsigned int)bitmap[bitmapOffset + 1];
                    float b = (unsigned int)bitmap[bitmapOffset + 2];
                    float a = (unsigned int)bitmap[bitmapOffset + 3];
                    
                    NSInteger dataOffset = (z * kDimension * kDimension + y * kDimension + x) * 4;
                    
                    data[dataOffset] = r / 255.0;
                    data[dataOffset + 1] = g / 255.0;
                    data[dataOffset + 2] = b / 255.0;
                    data[dataOffset + 3] = a / 255.0;
                    
                    bitmapOffset += 4;
                }
                z++;
            }
            z = tmp;
        }
        z += columnNum;
    }
    
    free(bitmap);
    
    return [NSData dataWithBytesNoCopy:data length:size freeWhenDone:YES];
  }

- (unsigned char *)createRGBABitmapFromImage:(CGImageRef)image
{
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
    return bitmap;
}

@end
