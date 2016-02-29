//
//  MFFDShader.h
//  FilterEngine
//
//  Created by mionyu on 14-8-26.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//
//  MFFD shader implemention
//  only do the warp job at this time, calculation the warping field not implemnted yet.


#import "GPUImageFilter.h"

@interface MFFDShader : GPUImageFilter
-(void) setFFDArr:(void*)ffdArr;
-(void)setCanvasOffset:(CGPoint)offset;
@end
