//
//  ImageProvider.h
//  FilterShowcase
//
//  Created by apple on 12-5-11.
//  Copyright (c) 2012年 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GPUImageOutput.h"

struct _Image;

@interface ImageProvider : GPUImageOutput
{
    int imageWidth;
    int imageHeight;
}
-(void)openImageWithURL:(NSURL *)url;
-(void)openImageRef:(CGImageRef)imageRef;
-(void)openImage:(UIImage*)image;
-(void)openImage:(UIImage*)image useDataProvider:(BOOL)useProvider;
- (void)openInternImage:(struct _Image *)image;
-(void)changeFilter;
-(void)setInputTexture:(unsigned char*)pixels width:(int)w height:(int)h;
-(void)updateImgeWithByte:(unsigned char*)textureData withWidth:(int)w  withHeight:(int)h;
@end


@interface ImageProviderNearest : ImageProvider

@end