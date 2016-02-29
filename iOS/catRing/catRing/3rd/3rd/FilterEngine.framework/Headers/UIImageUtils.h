//
//  UIImageUtils.h
//  MRCamera
//
//  Created by silson Liu on 12-8-9.
//  Copyright (c) 2012年 Microrapid. All rights reserved.
//

//#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum 
{
    MRCamera_Orientation_Up,
    MRCamera_Orientation_Down,
    MRCamera_Orientation_Left,
    MRCamera_Orientation_Right,
    MRCamera_Orientation_LeftRight,
    MRCamera_Orientation_UpDown,
} MRCamera_Orientation;

#define MRCamera_Orientation_Default MRCamera_Orientation_Up

@interface UIImageUtils : NSObject

/* UIImage Functions break Orientation */
+ (UIImage *)imageSetOrientation:(UIImage *)imageOrg Orientation:(MRCamera_Orientation)orientation;
+ (UIImage *)imageScale:(UIImage *)imageOrg toSize:(CGSize)toSize;
+ (UIImage *)imageScale2:(UIImage *)imageOrg toSize:(CGSize)toSize;
+ (UIImage *)imageScaleByBitmap:(UIImage *)image toSize:(CGSize)toSize;
+ (UIImage *)imageScale:(UIImage *)imageOrg toSize:(CGSize)toSize quality:(CGInterpolationQuality)quality;
+ (UIImage *)imageScale:(UIImage *)image toScale:(float)scaleSize;
+ (UIImage *)thumbImageScale:(UIImage *)imageOrg toSize:(CGSize)thumbSize;
+ (UIImage *)rotateImage:(UIImage *)image clockwise:(BOOL)clockwise;
+ (UIImage *)cropImage:(UIImage *)image ratio:(float)ratio;
+ (UIImageOrientation)imageOrientationRevertDeviceOrientation:(MRCamera_Orientation)deviceOrientation;
+ (UIImage *)image:(UIImage *)img cropToRect:(CGRect)rect;
+ (CGRect)frameFromImage:(UIImage *)image withLimits:(CGRect)limits;
+ (UIImageOrientation)combineImageOrientation:(UIImageOrientation)imageOrientation withDeviceOrientation:(MRCamera_Orientation)orientation;
+ (NSInteger)exifOrientationFromUIImageOrientation:(UIImageOrientation)imageOrientation;
+ (UIImageOrientation)UIImageOrientationFromExifOrientation:(NSInteger)exifOrientation;
+ (CGSize)sizeFromMetaData:(NSDictionary *)meta;
+ (UIImage *)cropImage:(UIImage *)image inRect:(CGRect)rect;
+ (CGFloat)scaleWithImage:(UIImage *)image inLimits:(CGRect)limits;

+ (CGSize)fitNewImageSize:(CGSize)imageSize toSize:(CGSize)size;
/* */

/* UIImage Functions with Orientation */
+ (UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)size;
+ (UIImage *)horizontalMirrorImage:(UIImage *)image;


+ (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)size withCapInsets:(UIEdgeInsets)capInsets;

#pragma mark - modify
+ (UIImage *)drawText:(NSString *)text atPoint:(CGPoint)point onImage:(UIImage *)image;
+ (UIImage *)landMark:(int [][2])feats count:(NSInteger)count color:(UIColor *)color onImage:(UIImage *)image;
+ (UIImage *)landNumberMark:(int [][2])feats count:(NSInteger)count color:(UIColor *)color onImage:(UIImage *)image;
+ (UIImage *)blendImage:(UIImage *)image1 withImage:(UIImage *)image2 atPoint:(CGPoint)point withMode:(CGBlendMode)blendMode;

@end
