//
//  LensFlareHandler.h
//  FilterEngine
//
//  Created by 刘银松 on 14/7/15.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LensFlareHandler : NSObject
- (void)initGPU;
- (void)updateSrcImage:(UIImage *)src;
- (void)updatePattern:(UIImage *)pattern;
- (void)updateOpType:(int)op;
- (void)updateStrength:(float)strength;
- (void)updateCrossNumStrength:(float)strength;
- (void)updateCrossSizeStrength:(float)strength;
- (void)removePoint:(float)x andY:(float)y;
- (void)revertDelEvent;
-(UIImage *)getResultImage;
@end
