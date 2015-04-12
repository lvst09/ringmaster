//
//  DWIplImageHelper.m
//  catRing
//
//  Created by sky on 15/2/20.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "DWIplImageHelper.h"



// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
IplImage *convertIplImageFromUIImage(UIImage *image) {
//    {
//        CGImageRef imgRef = aImage.CGImage;
//        
//        size_t imageWidth = CGImageGetWidth(imgRef);
//        size_t imageHeight = CGImageGetHeight(imgRef);
//        CGRect bounds = CGRectMake(0, 0, imageWidth, imageHeight);
//        CGSize correctSize = bounds.size;
//        
//        if (correctSize.width > imageWidth)
//        {
//            correctSize = CGSizeMake(imageWidth, imageHeight);
//            bounds.size = correctSize;
//        }
//        
//        bounds.origin = CGPointZero;
//        
//        UIImageOrientation orient = aImage.imageOrientation;
//        
//        CGFloat boundHeight;
//        
//        switch (orient)
//        {
//            case UIImageOrientationUp: //EXIF = 1
//                break;
//                
//            case UIImageOrientationUpMirrored: //EXIF = 2
//                break;
//                
//            case UIImageOrientationDown: //EXIF = 3
//                break;
//                
//            case UIImageOrientationDownMirrored: //EXIF = 4
//                break;
//                
//            case UIImageOrientationLeftMirrored: //EXIF = 5
//                boundHeight = bounds.size.height;
//                bounds.size.height = bounds.size.width;
//                bounds.size.width = boundHeight;
//                break;
//                
//            case UIImageOrientationLeft: //EXIF = 6
//                boundHeight = bounds.size.height;
//                bounds.size.height = bounds.size.width;
//                bounds.size.width = boundHeight;
//                break;
//                
//            case UIImageOrientationRightMirrored: //EXIF = 7
//                boundHeight = bounds.size.height;
//                bounds.size.height = bounds.size.width;
//                bounds.size.width = boundHeight;
//                break;
//                
//            case UIImageOrientationRight: //EXIF = 8
//                boundHeight = bounds.size.height;
//                bounds.size.height = bounds.size.width;
//                bounds.size.width = boundHeight;
//                break;
//                
//            default:
//                [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
//        }
//        
//        CGContextRef context = [RenderHelper newCreateRender:nil width:bounds.size.width height:bounds.size.height];
//        
//        CGAffineTransform trans = [self transformForOrientation: bounds.size orientation:orient];
//        CGContextConcatCTM(context, trans);
//        
//        CGContextSetInterpolationQuality(context, quality);
//        
//        CGContextDrawImage(context, CGRectMake(0, 0, correctSize.width, correctSize.height), imgRef);
//        
//        CGImageRef image = CGBitmapContextCreateImage(context);
//        
//        UIImage * resultImage = [UIImage imageWithCGImage:image];
//        
//        CGImageRelease(image);
//        
//        CGContextRelease(context);
//        
//        return resultImage;
//    }
    // Getting CGImage from UIImage
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temporal IplImage for drawing
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4);
    
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height, iplimage->depth, iplimage->widthStep, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    
    // Drawing CGImage to CGContext
    CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}


// NOTE You should convert color mode as RGB before passing to this function
UIImage * convertUIImageFromIplImage(IplImage *image) {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
}


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
void rotate_image_90n(cv::Mat &src, cv::Mat &dst, int angle)
{
    if(src.data != dst.data){
        src.copyTo(dst);
    }
    
    angle = ((angle / 90) % 4) * 90;
    
    //0 : flip vertical; 1 flip horizontal
    bool const flip_horizontal_or_vertical = angle > 0 ? 1 : 0;
    int const number = std::abs(angle / 90);
    
    for(int i = 0; i != number; ++i){
        cv::transpose(dst, dst);
        cv::flip(dst, dst, flip_horizontal_or_vertical);
    }
}