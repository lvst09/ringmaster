//
//  DWVideoDecoding.m
//  ttpic
//
//  Created by sky on 15/1/10.
//  Copyright (c) 2015年 Tencent. All rights reserved.
//

#import "DWVideoDecoding.h"
@import AVFoundation;

@interface DWVideoDecoding()

@property (nonatomic, strong) AVAssetReaderTrackOutput* assetReaderOutput;

@property (nonatomic, strong) AVAssetReader *assetReader;

@end

@implementation DWVideoDecoding

+ (UIImage *)processSampleBuffer:(CMSampleBufferRef)sampleBuffer imageOrientation:(UIImageOrientation)orientation {
    CMSampleBufferGetFormatDescription(sampleBuffer);
    UIImage *image = nil;
    @autoreleasepool {
        CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        CVPixelBufferLockBaseAddress(imageBuffer, 0);
        void *baseAddress = CVPixelBufferGetBaseAddress(imageBuffer);
        size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
        size_t width = CVPixelBufferGetWidth(imageBuffer);
        size_t height = CVPixelBufferGetHeight(imageBuffer);
        
        static CGColorSpaceRef colorSpace = nil;
        if (colorSpace == nil) {
            colorSpace = CGColorSpaceCreateDeviceRGB();
        }
        
        NSLog(@"Started DrawVideoFrame\n");
        
        CVPixelBufferRef pixelBuffer = NULL;
        CFDictionaryRef attrs = (__bridge CFDictionaryRef)@{(id)kCVPixelBufferWidthKey: @(width), (id)kCVPixelBufferHeightKey: @(height), (id)kCVPixelBufferPixelFormatTypeKey: @(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange), /*kCVPixelFormatType_32BGRA*/ (id)kCVPixelBufferIOSurfacePropertiesKey: @{}, };
        
        CVReturn ret = CVPixelBufferCreateWithBytes(kCFAllocatorDefault, width, height, kCVPixelFormatType_420YpCbCr8BiPlanarFullRange, baseAddress, bytesPerRow, 0, 0, attrs, &pixelBuffer);
        
        if(ret != kCVReturnSuccess) {
            NSLog(@"CVPixelBufferRelease Failed");
            CVPixelBufferRelease(pixelBuffer);
        }
        
        CGContextRef context = CGBitmapContextCreate(baseAddress, width, height, 8, bytesPerRow, colorSpace, kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
        CGImageRef quartzImage = CGBitmapContextCreateImage(context);
        image = [UIImage imageWithCGImage:quartzImage scale:1.0f orientation:orientation];
        CGImageRelease(quartzImage);
        CVPixelBufferUnlockBaseAddress(imageBuffer,0);
        CGContextRelease(context);
    }
    return image;
}


- (instancetype)initWithMoviePath:(NSString *)path {
    if (self = [super init]) {
        NSURL *url = [NSURL fileURLWithPath:path];
        AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:url options:nil];
        
        NSError *error = nil;
        AVAssetReader *asset_reader = [[AVAssetReader alloc] initWithAsset:asset error:&error];
        NSLog(@"error=%@, reader=%@", error, asset_reader);
        NSArray* video_tracks = [asset tracksWithMediaType:AVMediaTypeVideo];
        AVAssetTrack* video_track = [video_tracks objectAtIndex:0];
        NSMutableDictionary* dictionary = [[NSMutableDictionary alloc] init];
        [dictionary setObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(NSString*)kCVPixelBufferPixelFormatTypeKey];
        AVAssetReaderTrackOutput* asset_reader_output = [[AVAssetReaderTrackOutput alloc] initWithTrack:video_track outputSettings:dictionary];
        self.assetReaderOutput = asset_reader_output;
        [asset_reader addOutput:asset_reader_output];
        [asset_reader startReading];
        self.assetReader = asset_reader;
    }
    return self;
}

- (UIImage *)fetchOneFrame {
    CMSampleBufferRef buffer;
    if ([self.assetReader status] == AVAssetReaderStatusReading) {
        buffer = [self.assetReaderOutput copyNextSampleBuffer];
        //            DLog(@"buffer=%@", buffer);
//        CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(buffer);
//        CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(buffer);
        UIImage *image = [DWVideoDecoding processSampleBuffer:buffer imageOrientation:UIImageOrientationDown];
        NSLog(@"image size=%@", [NSValue valueWithCGSize:image.size]);
        return image;
    }
    return nil;
}

@end
