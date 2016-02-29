//
//  CosmeticsHandle.h
//  FilterEngine
//
//  Created by  patyang on 14-3-4.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import <UIKit/UIKit.h>

struct _Image;
@class FaceDetectorFeature;

@interface CosmeticsHandle : NSObject

@property (nonatomic, retain) UIImage *image;
@property (nonatomic, retain) FaceDetectorFeature *feature;
@property (nonatomic, assign) BOOL haveFace;
@property (nonatomic, assign) BOOL isGPU;

- (id)initWithImage:(UIImage *)image;
- (void)setFaceOutline:(int [83][2])outline;
- (void)getFaceOutline:(int [83][2])outline;
- (void)initHair;
- (void)setManualHairMask:(struct _Image *)hairMask type:(int)type;

- (BOOL)canManualUndo:(NSInteger)type;
- (BOOL)canManualRedo:(NSInteger)type;
- (void)manualUndo:(NSInteger)type;
- (void)manualRedo:(NSInteger)type;
- (void)manualCancelAdjust:(NSInteger)type;
- (void)manualAcceptAdjust:(NSInteger)type;

- (double)cosAlphaOfType:(NSInteger)type;
- (void)setCosAlpha:(double)alpha ofType:(NSInteger)type;
- (int)cosParamOfType:(NSInteger)type;
- (void)setCosParam:(int)param ofType:(NSInteger)type;

- (void)setIrisColorIndex:(NSInteger)index;
- (void)setLipsColorIndex:(NSInteger)index;
- (void)setBasicColorIndex:(NSInteger)index;
- (void)setBlushColorIndex:(NSInteger)index;
- (void)setHairColorIndex:(NSInteger)index;

- (void)setIrisColorWithRed:(int)red green:(int)green blue:(int)blue;
- (void)setLipsColorWithRed:(int)red green:(int)green blue:(int)blue;
- (void)setBasicColorWithRed:(int)red green:(int)green blue:(int)blue;
- (void)setBlushColorWithRed:(int)red green:(int)green blue:(int)blue;
- (void)setHairColorWithRed:(int)red green:(int)green blue:(int)blue;

- (void)setRssColorWithRed:(int)red green:(int)green blue:(int)blue ofType:(NSInteger)type;
- (void)setRssIndex:(NSInteger)index image:(UIImage *)image ofType:(NSInteger)type;
- (void)reset;
- (void)cosmetic;
- (void)cosmeticAdjust;
- (void)enableLightNose;
- (BOOL)isAllDisable;
- (void)clearCosmeticCache:(NSInteger)type;
- (void)adjustFeaturesWithBegin:(CGPoint)begin end:(CGPoint)end type:(int)type flag:(int)flag;
- (UIImage *)resultImage;
- (UIImage *)landMarkImageWithColor:(UIColor *)color;

- (void) doFaceSmooth;

/// UI
- (NSInteger)irisColorModalCount;
- (UIImage *)irisColorModalImageAtIndex:(NSInteger)index;
- (NSInteger)lipsColorModalCount;
- (UIImage *)lipsColorModalImageAtIndex:(NSInteger)index;
- (NSInteger)basicColorModalCount;
- (UIImage *)basicColorModalImageAtIndex:(NSInteger)index;
- (NSInteger)blushColorModalCount;
- (UIImage *)blushColorModalImageAtIndex:(NSInteger)index;
- (NSInteger)hairColorCount;
- (UIImage *)hairColorModalImageAtIndex:(NSInteger)index;

@end
