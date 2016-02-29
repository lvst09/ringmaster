//
//  MRFaceHandle.h
//  FilterShowcase
//
//  Created by apple on 12-6-25.
//  Copyright (c) 2012年 Cell Phone. All rights reserved.
//

#import <UIKit/UIKit.h>

struct _Rect;
@class FaceDetectorFeature;

@interface MRFaceHandle : NSObject

@property (nonatomic, retain) FaceDetectorFeature *feature;
@property (nonatomic, assign) double global_whiten;
@property (nonatomic, assign) double skin_brighten;
@property (nonatomic, assign) double skin_whiten;
@property (nonatomic, assign) double skin_smooth;
@property (nonatomic, assign) double anti_spot;
@property (nonatomic, assign) double slim_face;
@property (nonatomic, assign) int face_type;
@property (nonatomic, assign) double skin_color;
@property (nonatomic, assign) double eye_enlarge;
@property (nonatomic, assign) double eye_lighten;
@property (nonatomic, assign) double eye_bag;
@property (nonatomic, assign) BOOL skin_smooth_changed;
@property (nonatomic, assign) BOOL need_auto_contrast;
@property (nonatomic, assign) BOOL is_gpu;
@property (nonatomic, assign) BOOL aboveIPhone4;

- (id)initWithImage:(UIImage *)image;
- (void)setImage:(UIImage *)image;
- (void)detectHumanFace;
- (void)processImage;
- (UIImage *)handledImage;
- (BOOL)faceFound;

@end
