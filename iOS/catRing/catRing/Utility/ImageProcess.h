//
//  ImageProcess.h
//
//
//  Created by Sky on 7/8/11.
//  Copyright 2011 DW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface ImageProcess : NSObject

+ (CGImageRef)scaleImage:(CGImageRef)imgRef withSize:(CGFloat)size;

+ (UIImage*)resizeImage:(NSData*)data size:(int)size withRatio:(BOOL)withRatio;

+ (UIImage*)cropImage:(UIImage*)img InWidth:(CGFloat)cropWidth height:(CGFloat)cropHeight withScale:(BOOL)s;

+ (UIImage*)createSquareThumbnail:(UIImage *)img size:(int)size;

// 校正图片的旋转方向,保持图像的面积不变
+ (UIImage *)correctImage:(UIImage *)aImage;
+ (UIImage *)correctImage:(UIImage *)aImage drawQuality:(CGInterpolationQuality) quality;;
+ (UIImage *)fastCorrectImage:(UIImage *)aImage toFitIn:(CGSize)fitSize;

// 校正图片的旋转方向，同时将图片大小压缩至屏幕大小
+ (UIImage *)correctImage:(UIImage *)aImage toFitIn: (CGSize) fitSize;
+ (UIImage *)correctImage:(UIImage *)aImage toFitIn: (CGSize) fitSize drawQuality:(CGInterpolationQuality) quality;
+ (UIImage *)correctImage:(UIImage *)aImage toFillIn: (CGSize) fitSize;

+ (CGAffineTransform)transformForOrientation:(CGSize)newSize orientation: (UIImageOrientation) orientation;

@end
