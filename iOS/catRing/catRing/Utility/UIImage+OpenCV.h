//
//  UIImage+OpenCV.h
//  catRing
//
//  Created by sky on 15/4/12.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import <UIKit/UIKit.h>

// opencv
#import <opencv2/highgui/ios.h>
#import <opencv2/core/core_c.h>
#import <opencv2/core/core.hpp>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgproc/imgproc_c.h>
#import <opencv2/imgproc/imgproc.hpp>
// opencv

@interface UIImage (UIImage_OpenCV)

+(UIImage *)imageWithCVMat:(const cv::Mat&)cvMat;
-(id)initWithCVMat:(const cv::Mat&)cvMat;

@property(nonatomic, readonly) cv::Mat CVMat;
@property(nonatomic, readonly) cv::Mat CVGrayscaleMat;

@end
