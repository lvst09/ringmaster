//
//  MagicPenHandler.h
//  FilterEngine
//
//  Created by apple on 14/7/15.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MagicPenHandler : NSObject
- (void)initGPU;
- (void)updateSrcImage:(UIImage *)src;
- (void)updatePattern:(UIImage *)src;
- (void)updatePatternImageList:(NSMutableArray *)imglist;
- (void)updateCurrentPos:(float)x andY:(float)y;
- (void)updateLastPos:(float)x andY:(float)y;
- (void)updateOpType:(int)type; //0-add, 1-remove
- (void)updatePatternType:(int)type;
- (void)updatePaintType:(int)type;
- (void)updateTouchStatus:(int)type;
- (void)pushbackBuffer;
- (void)undo;
- (void)redo;
- (bool)canUndo;
- (bool)canRedo;
-(UIImage *)getSrcImage;
-(UIImage *)getResultImage;
- (void)reset;
@end

