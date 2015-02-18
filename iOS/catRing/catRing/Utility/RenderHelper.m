//
//  Render.m
//  seagullHD
//
//  Created by mikedong on 11-6-3.
//  Copyright 2011年 tencent. All rights reserved.
//

#import "RenderHelper.h"
//#import "NSString+TextSize.h"


@implementation RenderHelper

+ (CGContextRef) newCreateRender: (void *) pixelData
                        width: (size_t) width
                       height: (size_t) height
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == nil)
    {
        NSLog(@"Failed to create color space");
        return NULL;
    }
    
    CGContextRef context = CGBitmapContextCreate(pixelData, 
                                                 width, 
                                                 height,
                                                 8,
                                                 width * 4, 
                                                 colorSpace, 
                                                 (CGBitmapInfo)kCGImageAlphaPremultipliedLast);
    
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

+ (CGContextRef) newCreateTransParentRender: (void *) pixelData 
                                   width: (size_t) width 
                                  height: (size_t) height
{
    CGContextRef context = [RenderHelper newCreateRender:pixelData width:width height:height];
    
    CGContextSetRGBFillColor(context, 1, 1, 1, 0);
    CGContextFillRect(context, CGRectMake(0, 0, width, height));
    
    return context;
}

+ (CGLayerRef) newCreateLayer: (UIImage *) image
{
    if (image != nil)
    {
        size_t imageWidth = CGImageGetWidth([image CGImage]);
        size_t imageHeight = CGImageGetHeight([image CGImage]);
        
        CGContextRef context = [RenderHelper newCreateRender: nil width: imageWidth height:imageHeight];
        
        CGLayerRef layer = CGLayerCreateWithContext(context,CGSizeMake(imageWidth,imageHeight),NULL);
        CGContextRelease(context);
        
        CGContextRef layerContext = CGLayerGetContext(layer);
        
        CGContextDrawImage(layerContext, CGRectMake(0,0,imageWidth,imageHeight), [image CGImage]);
        
        return layer;
    }
    else
    {
        return nil;
    }
}

+ (UIImage *) GetImageFromRender: (CGContextRef) context
{
    CGImageRef imageRef = CGBitmapContextCreateImage(context);
    UIImage * resultImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return resultImage;
}

+ (void) MirroCoordination: (CGContextRef) context
                    height: (CGFloat) height
{
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -height);
}

@end


//CGRect getTextArea(NSString * strText, UIFont * font, CGRect bounds)
//{
//    CGSize constrainedSize = CGSizeMake(bounds.size.width, 1000);
//    CGSize textSize = [strText sizeWithFontV2:font
//                          constrainedToSize:constrainedSize 
//                              lineBreakMode:UILineBreakModeWordWrap];
//    
//    CGRect textArea = CGRectMake(0, bounds.origin.y + (bounds.size.height - textSize.height) / 2, bounds.size.width, textSize.height);
//    textArea.origin.y = roundf(textArea.origin.y);
//    return textArea;
//}

// 最大字号的问题
//CGFloat getBestFontSizeWithMiniSize(NSString * strText, NSString * fontName, CGRect rect, CGFloat miniSize, UILineBreakMode breakMode)
//{
//    static CGFloat defaultFontSize = 32;
//    CGFloat minFontSize = miniSize;
//    static CGFloat maxFontSize = 256;   // 128
//    static CGFloat smallFontInterval = 2;
//    static CGFloat bigFontInterval = 2;
//    
//    CGSize borderSize = CGSizeMake(rect.size.width, 10000);
//    CGFloat actualFontSize = defaultFontSize;
//    CGFloat bestSize = actualFontSize;
//    CGSize textSize = [strText sizeWithFontV2:[UIFont fontWithName:fontName size:actualFontSize]
//                   constrainedToSize:borderSize
//                       lineBreakMode:breakMode];
//    
//    if (textSize.height > rect.size.height)
//    {
//        actualFontSize -= smallFontInterval;
//        while (actualFontSize >= minFontSize)
//        {
//            textSize = [strText sizeWithFontV2:[UIFont fontWithName:fontName size:actualFontSize]
//                           constrainedToSize:borderSize
//                               lineBreakMode:breakMode];
//            if (textSize.height < rect.size.height)
//            {
//                bestSize = actualFontSize;
//                break;
//            }
//            bestSize = actualFontSize;
//            actualFontSize -= smallFontInterval;
//        }
//    }
//    else if (textSize.height < rect.size.height)
//    {
//        actualFontSize += bigFontInterval;
//        while (actualFontSize <= maxFontSize)
//        {
//            textSize = [strText sizeWithFontV2:[UIFont fontWithName:fontName size:actualFontSize]
//                           constrainedToSize:borderSize
//                               lineBreakMode:breakMode];
//            if (textSize.height > rect.size.height)
//            {
//                break;
//            }
//            bestSize = actualFontSize;
//            actualFontSize += bigFontInterval;
//        }
//    }
//    
//    return bestSize;
//}
//
//CGFloat getBestFontSize(NSString * strText, NSString * fontName, CGRect rect)
//{
//    return getBestFontSizeWithMiniSize(strText, fontName, rect, 4, UILineBreakModeWordWrap);
//}

BOOL fontInstalled(NSString * strFontName)
{
    UIFont * font = [UIFont fontWithName:strFontName size:12];
    if (font != nil)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}
