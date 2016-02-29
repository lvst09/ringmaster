//
//  SwapFaceHandle.h
//  MyCam
//
//  Created by silson on 13-11-22.
//  Copyright (c) 2013年 Microrapid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface SwapFaceHandle : NSObject

- (void)setImageA:(UIImage *)image hasFace:(BOOL)has outline:(int[83][2])outline modified:(int [83][2])modified;
- (void)setImageB:(UIImage *)image hasFace:(BOOL)has outline:(int[83][2])outline modified:(int [83][2])modified;
- (void)swapFaceFromAtoB:(void(^)(UIImage *image))block;
- (void)swapFaceFromBtoA:(void(^)(UIImage *image))block;
- (void)swapFaceFrom:(BOOL)AtoB block:(void(^)(UIImage *image))block;

@end
