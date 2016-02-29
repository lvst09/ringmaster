//
//  FaceDetector.h
//  FilterEngine
//
//  Created by  patyang on 14-3-4.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "ImageDefine.h"

@class UIImage;

typedef enum {
    FaceDetector_System = 0,
    FaceDetector_FacePP,
    FaceDetector_Youtu,
    FaceDetector_OpenCV
} FaceDetectorType;

typedef enum {
    FaceDetectorAccuracyLow = 0,
    FaceDetectorAccuracyHigh
} FaceDetectorAccuracy;

@interface FaceDetectorFeature : NSObject

@property (nonatomic, assign) CGSize imageSize;
@property (nonatomic, assign) CGRect bounds;
@property (nonatomic, assign) CGRect leBounds;
@property (nonatomic, assign) CGRect reBounds;
@property (nonatomic, assign) CGRect mouthBounds;

- (void)setFeatures:(int [FACE_FEATURE_NUM][2])points;
- (void)getFeatures:(int [FACE_FEATURE_NUM][2])points;
- (void)setScaleX:(CGFloat)scaleX scaleY:(CGFloat)scaleY;
- (void)updateImageSize:(CGSize)imageSize;
- (BOOL)correct;

@end

@interface FaceDetector : NSObject
{
    NSMutableArray *faces;
}

@property (nonatomic, assign) FaceDetectorAccuracy accuracy;

+ (FaceDetector *)createDetector:(FaceDetectorType)type;
+ (BOOL)isDetectorTypeAvailable:(FaceDetectorType)type;
- (void)detectFaceFeature:(UIImage *)image;
- (void)detectFaceFeature:(UIImage *)image withFaceRect:(CGRect)rect;
- (void)detectFaceFeature:(UIImage *)image withLeftEye:(CGPoint)left rightEye:(CGPoint)right;
- (UIImage *)formatInputImage:(UIImage *)image;
- (NSInteger)faceCount;
- (BOOL)isFemaleFaceAtIndex:(NSInteger)index;
- (CGPoint)leftEyeCenterAtIndex:(NSInteger)index;
- (CGPoint)rightEyeCenterAtIndex:(NSInteger)index;
- (struct _Rect)faceRectAtIndex:(NSInteger)index;
- (struct _Rect)leftEyeRectAtIndex:(NSInteger)index;
- (struct _Rect)rightEyeRectAtIndex:(NSInteger)index;
- (struct _Rect)mouthRectAtIndex:(NSInteger)index;
- (void)getFeaturePoints:(int [FACE_FEATURE_NUM][2])points atIndex:(NSInteger)index;
- (FaceDetectorFeature *)featureAtIndex:(NSInteger)index;

- (BOOL)correctFaceRect:(struct _Rect *)faceRect leRect:(struct _Rect *)leRect reRect:(struct _Rect *)reRect mouthRect:(struct _Rect *)mouthRect width:(int)width height:(int)height;

@end