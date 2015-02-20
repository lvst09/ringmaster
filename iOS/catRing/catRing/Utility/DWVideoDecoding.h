//
//  DWVideoDecoding.h
//  ttpic
//
//  Created by sky on 15/1/10.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CoreMedia/CoreMedia.h>

@interface DWVideoDecoding : NSObject

+ (UIImage *)processSampleBuffer:(CMSampleBufferRef)sampleBuffer imageOrientation:(UIImageOrientation)orientation;

- (instancetype)initWithMoviePath:(NSString *)path;

//- (void)processVideoInPath:(NSString *)path;

- (UIImage *)fetchOneFrame;

@end
