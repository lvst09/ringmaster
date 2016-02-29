//
//  ImageSelectorHandle.h
//  FilterEngine
//
//  Created by  patyang on 14-3-26.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import <UIKit/UIKit.h>

struct _Image;

typedef enum {
    PaintType_Select = 0,
    PaintType_LazySanpping,
} PaintType;

typedef enum {
    PaintMode_SmartBrush = 0,
    PaintMode_SmartEraser,
    PaintMode_NormalBrush,
    PaintMode_NormalEraser
} PaintMode;


@interface ImageSelectorHandle : NSObject
{
    struct _Image *selectedImage;
    CGPoint lastPoint;
}

@property (nonatomic, assign) PaintMode mode;

- (id)initWithImage:(UIImage *)image;
+ (ImageSelectorHandle *)handleWithType:(PaintType)type image:(UIImage *)image;
- (BOOL)isRedImage;
- (void)setImage:(UIImage *)image;
- (struct _Image *)getSelectMask;
- (void)setSelectMask:(struct _Image *)mask;
- (struct _Image *)maskFromFore:(struct _Image *)fore rect:(CGRect)rect size:(CGSize)size maskSize:(CGSize)maskSize;
- (struct _Image *)maskFromBack:(struct _Image *)back rect:(CGRect)rect size:(CGSize)size maskSize:(CGSize)maskSize;
- (void)setMaskImage:(struct _Image *)maskImage withRect:(CGRect)rect;
- (UIImage *)getOriginalUIImage;
- (struct _Image *)getSelectedImage;
- (UIImage *)getSelectedUIImage;
- (CGRect)getSelectedRect;
- (struct _Image *)getForeGroundImage;
- (UIImage *)getForeGroundUIImage;
- (UIImage *)getBackGroundUIImage;
- (void)touchBeganAt:(CGPoint)point;
- (void)touchMovedTo:(CGPoint)point radius:(float)radius extend:(float)extendRadius;
- (void)touchEnded;
- (BOOL)canUndo;
- (BOOL)canRedo;
- (void)undo;
- (void)redo;

- (UIImage *)compositback:(UIImage *)back width:(int)width;
+ (NSArray *)forebackImageFromOrignin:(UIImage *)origin backImage:(UIImage *)back;

@end
