//
//  UIImageOrientationFilter.h
//  MyCam
//
//  Created by Patrick Yang on 13-7-25.
//  Copyright (c) 2013年 Microrapid. All rights reserved.
//

#import "GPUImageFilter.h"

// in GPUImageFilter.h
typedef enum {
    UIImageFlipNone = 0,
    UIImageFlipHorizontal,
    UIImageFlipVertical,
    UIImageFlipHorizontalVertical
} UIImageFlipMode;
typedef enum {
    UIImageFormatRGBA = 0,
    UIImageFormat420V,
    UIImageFormatCount
}UIImageFormat;


@interface UIImageOrientationFilter : GPUImageFilter


- (void)setOrientationMode:(UIImageOrientation)orientationMode;
- (void)setFlipMode:(UIImageFlipMode)flipMode;
- (void)setInputImage:(UIImage *)image;
- (void)setInputPixelBuffer:(CVPixelBufferRef)buffer withFormat:(int)format;

@end
