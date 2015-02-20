//
//  DWIplImageHelper.h
//  catRing
//
//  Created by sky on 15/2/20.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// opencv
#import <opencv2/highgui/ios.h>
#import <opencv2/core/core_c.h>
#import <opencv2/imgproc/types_c.h>
#import <opencv2/imgproc/imgproc_c.h>
// opencv

// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
IplImage *convertIplImageFromUIImage(UIImage *image);


// NOTE You should convert color mode as RGB before passing to this function
UIImage * convertUIImageFromIplImage(IplImage *image);