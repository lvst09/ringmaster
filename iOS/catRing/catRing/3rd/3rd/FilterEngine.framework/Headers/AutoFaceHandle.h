//
//  AutoFaceHandle.h
//  FilterEngine
//
//  Created by patyang on 14/12/12.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AutoFaceDefine.h"

typedef enum _AutoFilterStyle {
    AutoFilterStyle_None = -1,
    AutoFilterStyle_Ziran,
    AutoFilterStyle_Hongrun,
    AutoFilterStyle_Baixi,
    AutoFilterStyle_TianMei,
    AutoFilterStyle_MengHuan,
    AutoFilterStyle_YangGuang,
    AutoFilterStyle_RouNen,
    AutoFilterStyle_Total
} AutoFilterStyle;

typedef enum _AutoFilterQuality {
    AutoFilterQuality_None = -1,
    AutoFilterQuality_Low,
    AutoFilterQuality_Medium,
    AutoFilterQuality_High
} AutoFilterQuality;

@class FaceDetectorFeature;

@interface AutoFaceHandle : NSObject

@property (nonatomic, strong) UIImage *image;
@property (nonatomic, strong) FaceDetectorFeature *feature;
@property (nonatomic, assign) BOOL aboveIPhone4;
@property (nonatomic, assign) AutoFilterStyle filterStyle;
@property (nonatomic, assign) AutoFilterQuality filterQuality;

- (float)autoParamOfType:(AUTO_FACE_TYPE)type;
- (void)setAutoParam:(float)param ofType:(AUTO_FACE_TYPE)type;
- (void)processImage;
- (UIImage *)resultImage;

@end
