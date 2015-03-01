//
//  CameraVideoDevice.h
//
//
//  Created by sky on 13-5-21.
//  Copyright (c) 2013年 DW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "CameraTypes.h"

#define USE_YUV 0

@protocol CameraVideoDeviceDelegate <NSObject>

- (void)cameraDeviceEvent:(CameraDeviceEvent)event withAguments:(NSDictionary *)args;

@end

@interface CameraVideoDevice : NSObject

@property (nonatomic, weak) NSObject<CameraVideoDeviceDelegate> *delegate;
@property (nonatomic, retain) AVCaptureSession *session;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) BOOL pause;
@property (nonatomic, assign) AVCaptureDevicePosition position;
@property (nonatomic, assign) CGPoint focustPoint;
@property (nonatomic, assign) CGPoint exposurePoint;
@property (nonatomic, assign) int32_t exposureDuration;
@property (nonatomic, assign) CameraFlashMode flashMode;
@property (nonatomic, assign) BOOL lowLightBoost;
@property (nonatomic, assign, readonly) BOOL hasFlash;
@property (nonatomic, assign, readonly) BOOL hasFront;


- (id)initWithSessionPreset:(NSString *)preset cameraPosition:(AVCaptureDevicePosition)position;
+ (BOOL)deviceDenied;
- (void)startDevice;
- (void)stopDevice;

- (void)startRecording;
- (void)stopRecording;

- (void)beginConfiguration;
- (void)commitConfiguration;

@end
