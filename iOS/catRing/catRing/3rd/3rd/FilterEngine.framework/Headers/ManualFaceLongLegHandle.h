//
//  ManualFaceLongLegHandle.h
//  FilterEngine
//
//  Created by patyang on 14/8/29.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import <UIKit/UIKit.h>

struct _Image;

@interface ManualFaceLongLegHandle : NSObject

- (id)initWithUIImage:(UIImage *)image;
- (void)setRange:(NSRange)range;
- (NSRange)getRange;
- (void)setMagValue:(float)magValue;
- (BOOL)canUndo;
- (BOOL)canRedo;
- (void)undo;
- (void)redo;
- (BOOL)isClean;
- (UIImage *)resultImage;

@end
