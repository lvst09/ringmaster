//
//  ImageProcess.m
//
//
//  Created by Sky on 7/8/11.
//  Copyright 2011 DW. All rights reserved.
//

#import "ImageProcess.h"

#import <ImageIO/ImageIO.h>

#import "MathUtil.h"
#import "RenderHelper.h"


@implementation ImageProcess

+ (CGImageRef)scaleImage:(CGImageRef)imgRef withSize:(CGFloat)size {
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGFloat scaleRatio = 0;
    
    if (width <= size && height <= size)
        return imgRef;
    
    if (width > size) {
        scaleRatio = size / width;
        width = size;
        height = height * scaleRatio;
    }
    
    if (height > size)
    {
        scaleRatio = size / height;
        height = size;
        width = width * scaleRatio;
    }
    
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    UIImage *tmpImage = [[UIImage alloc] initWithCGImage:imgRef];
    
    [tmpImage drawInRect:CGRectMake(0, 0, width, height)];
    
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();

    tmpImage = nil;
    
    return imageCopy.CGImage;
}

+ (UIImage*)resizeImage:(NSData*)data size:(int)size withRatio:(BOOL)withRatio
{
    CGImageRef thumbnailImage = NULL;
    CGImageSourceRef imageSource;
    CFDictionaryRef options = NULL;
    CFStringRef keys[3];
    CFTypeRef values[3];
    CFNumberRef thumbnailSize;
    
    imageSource = CGImageSourceCreateWithData((CFDataRef)data, NULL);
    
    if (imageSource == NULL) {
        NSLog(@"image source is null");
        return nil;
    }
    
    thumbnailSize = CFNumberCreate(NULL, kCFNumberIntType, &size);
    
    keys[0] = kCGImageSourceCreateThumbnailWithTransform;
    values[0] = (CFTypeRef)kCFBooleanTrue;
    keys[1] = kCGImageSourceCreateThumbnailFromImageIfAbsent;
    values[1] = (CFTypeRef)kCFBooleanTrue;
    keys[2] = kCGImageSourceThumbnailMaxPixelSize;
    values[2] = (CFTypeRef)thumbnailSize;
    
    options = CFDictionaryCreate(NULL, (const void**)keys, (const void **)values, 3, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    
    thumbnailImage = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, options);
    
    CFRelease(thumbnailSize);
    CFRelease(options);
    CFRelease(imageSource);
    
    if (thumbnailImage == NULL) {
        NSLog(@"thumbnail image is not created");
        return nil;
    }
    
    UIImage* returnImg = nil;
    
    //  截取区域
    if (!withRatio)
    {
        CGFloat width = CGImageGetWidth(thumbnailImage);
        CGFloat height = CGImageGetHeight(thumbnailImage);
        CGFloat x = 0.0f;
        CGFloat y = 0.0f;
        
        if (width > height)
        {
            x = (width - height) / 2;
            width = height;
        }
        else
        {
            y = (height - width) / 2;
            height = width;
        }
        
        CGImageRef imageRef = CGImageCreateWithImageInRect(thumbnailImage, CGRectMake(x, y, width, height));
        returnImg = [UIImage imageWithCGImage:imageRef];
        CGImageRelease(imageRef);
    }
    else
    {
        returnImg = [UIImage imageWithCGImage:thumbnailImage];
    }
    
    CGImageRelease(thumbnailImage);
    
    return returnImg;
    
}


+ (UIImage*)cropImage:(UIImage*)img InWidth:(CGFloat)cropWidth height:(CGFloat)cropHeight withScale:(BOOL)s {
    
    CGFloat ratio = cropWidth / cropHeight;
    
    CGFloat width = img.size.width;
    CGFloat height = img.size.height;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    
    CGFloat r = width / height;
    
    UIImage* tmpImg = nil;
    
    if (s) {
        if (r < ratio) {
            tmpImg = [[UIImage alloc] initWithCGImage:[ImageProcess scaleImage:img.CGImage withSize:cropWidth/r]];
        } else {
            tmpImg = [[UIImage alloc] initWithCGImage:[ImageProcess scaleImage:img.CGImage withSize:cropHeight*r]];
        }
        
        width = tmpImg.size.width;
        height = tmpImg.size.height;
    }
    
    if (width / height < ratio) {
        y = height - width / ratio;
        height = width / ratio;
    } else {
        x = width - height * ratio;
        width = height *ratio;
    }
    
    CGImageRef imageRef = NULL;
    
    if (s)
        imageRef = CGImageCreateWithImageInRect([tmpImg CGImage], CGRectMake(x, y, width, height));
    else
        imageRef = CGImageCreateWithImageInRect([img CGImage], CGRectMake(x, y, width, height));
    
    UIImage* returnImg = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    tmpImg = nil;
    return returnImg;
}

+ (UIImage*)createSquareThumbnail:(UIImage *)img size:(int)size
{
    CGFloat width = img.size.width;
    CGFloat height = img.size.height;
    CGFloat x = 0.0f;
    CGFloat y = 0.0f;
    
    if (width > height)
    {
        x = (width - height) / 2;
        width = height;
    }
    else
    {
        y = (height - width) / 2;
        height = width;
    }
    
    CGRect cropRect = CGRectMake(x, y, width, height);
    CGImageRef imageRef = CGImageCreateWithImageInRect(img.CGImage, cropRect);
    
    UIImage* convertImg = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return convertImg;
}

+ (UIImage *) correctImage:(UIImage *)aImage
{
    return [ImageProcess correctImage:aImage drawQuality:kCGInterpolationHigh];
}

+ (UIImage *)correctImage:(UIImage *)aImage drawQuality:(CGInterpolationQuality)quality
{
    CGImageRef imgRef = aImage.CGImage;
    
    size_t imageWidth = CGImageGetWidth(imgRef);
    size_t imageHeight = CGImageGetHeight(imgRef);
    CGRect bounds = CGRectMake(0, 0, imageWidth, imageHeight);
    CGSize correctSize = bounds.size;
    
    if (correctSize.width > imageWidth)
    {
        correctSize = CGSizeMake(imageWidth, imageHeight);
        bounds.size = correctSize;
    }
    
    bounds.origin = CGPointZero;
    
    UIImageOrientation orient = aImage.imageOrientation;
    
    CGFloat boundHeight;
    
    switch (orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    CGContextRef context = [RenderHelper newCreateRender:nil width:bounds.size.width height:bounds.size.height];
    
    CGAffineTransform trans = [self transformForOrientation: bounds.size orientation:orient];
    CGContextConcatCTM(context, trans);
    
    CGContextSetInterpolationQuality(context, quality);
    
    CGContextDrawImage(context, CGRectMake(0, 0, correctSize.width, correctSize.height), imgRef);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    UIImage * resultImage = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    
    CGContextRelease(context);
    
    return resultImage;
}

+ (UIImage *)fastCorrectImage:(UIImage *)aImage toFitIn:(CGSize)fitSize {
    
    CGRect bounds = getInnerRect(aImage.size, CGRectMake(0, 0, fitSize.width, fitSize.height));
    
    if (bounds.size.width > aImage.size.width || bounds.size.height > aImage.size.height) {
        bounds.size = aImage.size;
    }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, NO, aImage.scale);
    [aImage drawInRect:CGRectMake(0, 0, bounds.size.width, bounds.size.height) blendMode:kCGBlendModeCopy alpha:1.0f];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (UIImage *) correctImage:(UIImage *)aImage toFitIn: (CGSize) fitSize
{
    return [ImageProcess correctImage:aImage toFitIn:fitSize drawQuality:kCGInterpolationHigh];
}

+ (UIImage *)correctImage:(UIImage *)aImage toFitIn:(CGSize)fitSize drawQuality:(CGInterpolationQuality)quality
{
    CGImageRef imgRef = aImage.CGImage;
    
    size_t imageWidth = CGImageGetWidth(imgRef);
    size_t imageHeight = CGImageGetHeight(imgRef);
    CGRect bounds = CGRectMake(0, 0, imageWidth, imageHeight);
    bounds = getInnerRect(bounds.size, CGRectMake(0, 0, fitSize.width, fitSize.height));
    CGSize correctSize = bounds.size;
    
    if (correctSize.width > imageWidth)
    {
        correctSize = CGSizeMake(imageWidth, imageHeight);
        bounds.size = correctSize;
    }
    
    bounds.origin = CGPointZero;
    
    UIImageOrientation orient = aImage.imageOrientation;
    
    CGFloat boundHeight;
    
    switch (orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    CGContextRef context = [RenderHelper newCreateRender:nil width:bounds.size.width height:bounds.size.height];
    
    CGAffineTransform trans = [self transformForOrientation: bounds.size orientation:orient];
    CGContextConcatCTM(context, trans);
    
    CGContextSetInterpolationQuality(context, quality);
    
    CGContextDrawImage(context, CGRectMake(0, 0, correctSize.width, correctSize.height), imgRef);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    UIImage * resultImage = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    
    CGContextRelease(context);
    
    return resultImage;
}

+(UIImage *)correctImage:(UIImage *)aImage toFillIn:(CGSize)fillSize{
    CGImageRef imgRef = aImage.CGImage;
    
    size_t imageWidth = CGImageGetWidth(imgRef);
    size_t imageHeight = CGImageGetHeight(imgRef);
    
    CGRect bounds = getInnerRect(CGSizeMake(imageWidth, imageHeight), CGRectMake(0, 0, fillSize.width, fillSize.height));
    
    CGContextRef context = [RenderHelper newCreateRender:nil width:fillSize.width height:fillSize.height];
    CGContextSetRGBFillColor(context, 0, 0, 0, 1);
    CGContextFillRect(context, CGRectMake(0, 0, fillSize.width, fillSize.height));
    CGAffineTransform trans = [self transformForOrientation:fillSize orientation:aImage.imageOrientation];
    CGContextConcatCTM(context, trans);
    
    CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
    
    CGContextDrawImage(context, bounds, imgRef);
    
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    UIImage * resultImage = [UIImage imageWithCGImage:image];
    
    CGImageRelease(image);
    
    CGContextRelease(context);
    
    return resultImage;
}

+ (CGAffineTransform)transformForOrientation:(CGSize)newSize orientation: (UIImageOrientation) orientation
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (orientation) {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        default:
            break;
    }
    
    switch (orientation) {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        default:
            break;
    }
    
    return transform;
}

@end
