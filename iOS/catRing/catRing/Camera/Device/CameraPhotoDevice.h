//
//  CameraPhotoDevice.h
//
//
//  Created by Sky on 13-5-21.
//  Copyright (c) 2013年 DW. All rights reserved.
//

#import "CameraVideoDevice.h"

typedef enum {
    // CameraPhotoDeviceNightModeAuto,
    CameraPhotoDeviceNightModeOff,
    CameraPhotoDeviceNightModeOn,
    
    CameraPhotoDeviceNightModeCount,
} CameraPhotoDeviceNightMode;

@interface CameraPhotoDevice : CameraVideoDevice

@property (nonatomic, assign) CameraPhotoDeviceNightMode nightMode;

- (id)initWithPosition:(AVCaptureDevicePosition)position;

- (void)capturePhotoWhenComplete:(void(^)(CMSampleBufferRef sampleBuffer, NSError *error))block;

@end
