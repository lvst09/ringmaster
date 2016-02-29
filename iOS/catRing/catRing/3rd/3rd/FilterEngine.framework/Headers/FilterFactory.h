//
//  FilterFactory.h
//  FilterShowcase
//
//  Created by Patrick Yang on 12-6-13.
//  Copyright (c) 2012年 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GPUImageFilter;
@class CPUImageFilter;

@interface FilterFactory : NSObject

@property (nonatomic, strong) NSString *bundleDirctory;

+ (FilterFactory *)shareFactory;

+ (dispatch_queue_t)filterQueue;
+ (void)runBlockInFilterQueueSync:(dispatch_block_t)block;
+ (void)runBlockInFilterQueueAsync:(dispatch_block_t)block;
+ (BOOL)isUsingFilterEngine;// DEFAULT:YES, TODO
+ (void)setUsingFilterEngine:(BOOL)use;
+ (void)freezeGPU;
+ (void)unfreezeGPU;

+ (GPUImageFilter *)createGPUFilter:(int)filterId;
+ (CPUImageFilter *)createCPUFilter:(int)filterId;
+ (GPUImageFilter *)createGPUFilter:(NSString *)filterId withIndex:(NSInteger)index;
+ (BOOL)isCPUFilter:(int)filterId;
+ (BOOL)isCPUParameterAdjust:(int)filterId;
+ (BOOL)isAlphaParameterAdjust:(int)filterId;
+ (int)isMultiParameter:(int)filterId;
+ (BOOL)canSaveForBigPhoto:(int)filterId;
+ (int)filterIdFromString:(NSString *)string effectIndex:(NSInteger)index;

@end
