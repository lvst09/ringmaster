//
//  ManualFaceHandle.h
//  FilterEngine
//
//  Created by  patyang on 14-4-23.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import <UIKit/UIKit.h>

#define MAX_UNDO_TIMES  (10)

struct _Image;

typedef enum {
    ManualFace_None = -1,
    ManualFace_EnlargeEye,
    ManualFace_LightEye,
    ManualFace_Patch,
    ManualFace_Pouch,
    ManualFace_Reshape,
    ManualFace_Smooth,
    ManualFace_Whiten
} ManualFaceType;

@interface ManualFaceHandle : NSObject


@property (nonatomic, assign) ManualFaceType type;
@property (nonatomic, assign) float radius;

+ (ManualFaceHandle *)handleWithType:(ManualFaceType)type image:(UIImage *)image;
- (id)initWithUIImage:(UIImage *)image andType:(ManualFaceType)type;
- (void)setUIImage:(UIImage *)image;
- (void)touchBeganAt:(CGPoint)point;
- (BOOL)touchMovedTo:(CGPoint)point;
- (void)touchEndedAt:(CGPoint)point;
- (BOOL)canUndo;
- (BOOL)canRedo;
- (void)undo;
- (void)redo;
- (BOOL)isClean;
- (UIImage *)resultImage;

@end
