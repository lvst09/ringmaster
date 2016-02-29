//
//  AnimotoHandler.h
//  FilterEngine
//
//  Created by  patyang on 14-2-27.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import "CPUImageFilter.h"
#import "GPUImageView.h"
#import "GPUImageRotationFilter.h"

@interface AnimotoHandler : NSObject

@property (nonatomic, retain) GPUImageView *bgimageView;
@property (nonatomic, retain) GPUImageView *fgimageView;
@property (nonatomic, retain) UIImageView *testimageView;
- (id)init:(CGRect)viewframe;
- (UIImage *)getFGImage:(float *)val andNewParam:(float *)param;
- (GPUImageRotationMode)getVideoOrientation;
- (bool)IsVideoEmpty:(NSURL *)url;
- (void)setMusicURL:(NSURL *)url;
- (void)setDateList:(NSMutableArray *)datearray andLocList:(NSMutableArray *)locarray;
- (void)updatelocListAt:(int)index withLocString:(NSString *)loc;
- (CVImageBufferRef)preProcessVideoFrame:(CVImageBufferRef)sampleBuffer;
- (bool)isVideoForceEnding;
- (void)setBlendAlpha:(float)alpha;
- (void)switchBlendOrder;
- (void)setBlendType:(int)type;
- (void)setVideoIndex:(int)index;
- (bool)isVideoCompleted;
- (bool)startProcess;
- (void)endProcess;
- (UIImage *)refineImageSize:(UIImage *)src;
- (void)setURL:(NSURL *)url withType:(int)videotype;
- (void)setImages:(NSMutableArray *)images;
- (UIImage *)cutImages:(UIImage *)image;
- (void)endVideoWriter;

@end

