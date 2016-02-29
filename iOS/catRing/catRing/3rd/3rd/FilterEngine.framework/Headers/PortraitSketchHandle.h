//
//  PortraitSketchHandle.h
//  FilterEngine
//
//  Created by patyang on 14-5-19.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PortraitSketchHandle : NSObject

- (UIImage *)sketchImage:(UIImage *)uiimg;
- (UIImage *)cartoonSketchImage:(UIImage *)uiimg;
- (UIImage *)genFaceHead:(UIImage *)uiimg;
- (UIImage *)landMarkImage:(UIImage *)image;
- (void)setFaceFeats:(int (*)[2])feats;
- (void)setFemale:(BOOL)female;

@end
