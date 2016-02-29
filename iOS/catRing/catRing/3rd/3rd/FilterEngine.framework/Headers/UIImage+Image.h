//
//  UIImage+Image.h
//  MyCamFilterEngine
//
//  Created by patyang on 14/9/23.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C"{
#endif

struct _Image;

    UIImage *Image2UIImage(struct _Image *image);
    struct _Image *UIImageToImage(UIImage *image);
    struct _Image *UIImage2Image(UIImage *uiImage);
    struct _Image *UIImage2Image2(UIImage *uiImage);
    UIImage *ImageRGBA2UIImage(struct _Image *image);
    struct _Image *UIImage2ImageRGBA(UIImage *uiImage);
    
    UIImage *createUIImageWithBytes(Byte *bytes, CGSize size, BOOL releaseBytes);
    UIImage *createUIImageWithImage(struct _Image *image, BOOL ignore, BOOL releaseBytes);
    UIImage *createUIImageWithCopyImage(struct _Image *image, BOOL copy);
    void fillImageByUIImage(UIImage *uiImage, struct _Image *image);
    
    
#ifdef __cplusplus
};
#endif