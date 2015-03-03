//
//  DWRotationManager.h
//  catRing
//
//  Created by sky on 15/3/1.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <GLKit/GLKit.h>
//@import CoreGraphics;
//@import GLKit;
#import "CCAppDelegate.h"

typedef void(^completeBlk)(NSMutableDictionary *outputDic);

@interface DWRotationManager : CCAppDelegate



@property (nonatomic, strong) NSMutableArray *input; // array of NSValue with GLKVector3

@property (nonatomic, strong) NSMutableDictionary *output;


+ (instancetype)sharedManager;

// angleX的单位是角度而非弧度
- (void)pushAngleX:(CGFloat)angleX angleY:(CGFloat)angleY angleZ:(CGFloat)angleZ;

// 先要通过pushAngleX来设置输入，然后通过getOutput异步地获取相应的结果。
- (void)getOutput:(completeBlk)blk controller:(UIViewController *)controller;

@end
