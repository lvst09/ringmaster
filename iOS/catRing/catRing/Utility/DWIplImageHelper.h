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


/*
 *@brief rotate image by factor of 90 degrees
 *
 *@param source : input image
 *@param dst : output image
 *@param angle : factor of 90, even it is not factor of 90, the angle
 * will be mapped to the range of [-360, 360].
 * {angle = 90n; n = {-4, -3, -2, -1, 0, 1, 2, 3, 4} }
 * if angle bigger than 360 or smaller than -360, the angle will
 * be map to -360 ~ 360.
 * mapping rule is : angle = ((angle / 90) % 4) * 90;
 *
 * ex : 89 will map to 0, 98 to 90, 179 to 90, 270 to 3, 360 to 0.
 *
 */
void rotate_image_90n(cv::Mat &src, cv::Mat &dst, int angle);