//
//  PaintEffectHandle.h
//  FilterEngine
//
//  Created by patyang on 14-3-10.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

struct _Image;

@interface PaintEffectHandle : NSObject

@property (nonatomic, assign) CGRect ROI;

+ (void)blurMask:(struct _Image *)mask;
#pragma mark - DOF
- (UIImage *)dofImage:(UIImage *)image withMask:(struct _Image *)mask;
#pragma mark - Bokeh
- (void)setWeight:(float)weight threshold:(float)threshold parameter:(float)parameter;
- (NSInteger)patternCount;
- (UIImage *)patternAtIndex:(NSInteger)index;
- (UIImage *)bokehImage:(UIImage *)image withPattern:(struct _Image *)pattern mask:(struct _Image *)mask;

@end
