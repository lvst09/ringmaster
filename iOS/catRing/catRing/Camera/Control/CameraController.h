//
//  CameraController.h
//  
//
//  Created by sky on 13-5-22.
//  Copyright (c) 2013年 DW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <FilterEngine/UIImageUtils.h>
#import "CameraPhotoDevice.h"
#import "CameraTypes.h"

typedef enum {
    TakePhotoFromButton = 0,
    TakePhotoFromVolumeKey = 1,
} TakePhotoFrom;

@class GPUImageView;
@class CameraControllerContext;

@protocol CameraControllerDelegate <NSObject>

// Delegate
- (CameraControllerContext *)cameraControllerContext;
- (GPUImageView *)imageViewOfDelegate;

// Event
- (void)cameraAttachmentMetadata:(CMSampleBufferRef)buffer;
- (void)cameraControllerEvent:(CameraControllerEvent)event withArgs:(NSDictionary *)args;

@end

@interface CameraControllerContext : NSObject

@property (nonatomic, assign) NSInteger postion;
@property (nonatomic, assign) NSInteger flashMdoe;
@property (nonatomic, assign) NSInteger exposureDuration;
@property (nonatomic, assign) NSInteger filterIndex;
@property (nonatomic, assign) NSInteger exposureLevel;

@end

@interface CameraController : NSObject

@property (nonatomic, assign, readonly) BOOL supportFlash;
@property (nonatomic, assign, readonly) BOOL supportFront;
@property (nonatomic, assign) AVCaptureDevicePosition devicePosition;
@property (nonatomic, assign) BOOL devicePaused;
@property (nonatomic, assign, readonly) BOOL running;
@property (nonatomic, assign) CameraFlashMode flashMode;
@property (nonatomic, assign) CGPoint focusPoint;
@property (nonatomic, assign) CGPoint exposurePoint;
@property (nonatomic, assign) CGFloat exposureLevel;
@property (nonatomic, assign) NSInteger exposureDuration;
@property (nonatomic, assign) NSInteger filterIndex;
@property (nonatomic, assign) BOOL notifyNextFrame;
@property (nonatomic, assign) BOOL cameraOrientation;

+ (CameraController *)shareController;
+ (BOOL)checkCameraAuthorization;
+ (void)prestartCamera;
- (void)startCamera;
- (void)stopCamera;
- (void)rotateCamera;
- (void)takePhotoWithOrientation:(MRCamera_Orientation)orientation andZoom:(CGFloat)zoom;
- (void)burstPhotos:(NSInteger)count;
- (void)pushDelegate:(NSObject<CameraControllerDelegate> *)delegate;
- (NSObject<CameraControllerDelegate> *)popDelegate;
- (NSObject<CameraControllerDelegate> *)currentDelegate;
- (void)clearVideoFrame;
- (void)freezeDevice;
- (void)unfreezeDevice;

@end
