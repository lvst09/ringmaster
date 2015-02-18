//
//  Render.h
//  seagullHD
//
//  Created by mikedong on 11-6-3.
//  Copyright 2011年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface RenderHelper : NSObject 
{    
}

// 根据数据和大小创建cotext
+ (CGContextRef) newCreateRender: (void *) pixelData 
                        width: (size_t) width
                       height: (size_t) height;

// 根据数据和大小创建透明cotext
+ (CGContextRef) newCreateTransParentRender: (void *) pixelData 
                                   width: (size_t) width
                                  height: (size_t) height;

+ (CGLayerRef) newCreateLayer: (UIImage *) image;
 
// 从context中获取图像，结果autorelease
+ (UIImage *) GetImageFromRender: (CGContextRef) context;

// 由于主界面和Quartz的坐标系在y轴方向是反的，因此需要纠正
+ (void) MirroCoordination: (CGContextRef) context 
                    height: (CGFloat) height;

@end

//CGRect getTextArea(NSString * strText, UIFont * font, CGRect bounds);

//CGFloat getBestFontSizeWithMiniSize(NSString * strText, NSString * fontName, CGRect rect, CGFloat miniSize, UILineBreakMode breakMode);
//CGFloat getBestFontSize(NSString * strText, NSString * fontName, CGRect rect);

BOOL fontInstalled(NSString * strFontName);