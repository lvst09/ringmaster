//
//  CameraPhotoDevice.m
//  
//
//  Created by sky on 13-5-21.
//  Copyright (c) 2013年 DW. All rights reserved.
//

#import "CameraPhotoDevice.h"

@interface CameraPhotoDevice ()
{
    AVCaptureStillImageOutput *photoOutput;
}

@end

@implementation CameraPhotoDevice

- (id)initWithPosition:(AVCaptureDevicePosition)position
{
    self = [super initWithSessionPreset:AVCaptureSessionPresetPhoto cameraPosition:position];
    if (!self) {
        return nil;
    }
    
    [self beginConfiguration];

    photoOutput = [[AVCaptureStillImageOutput alloc] init];
    [photoOutput setOutputSettings:[NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecJPEG, AVVideoCodecKey, nil]];
    if ([self.session canAddOutput:photoOutput]) {
        [self.session addOutput:photoOutput];
    }
    [self commitConfiguration];
    return self;
}

- (void)dealloc
{
    [self.session removeOutput:photoOutput];
}

- (void)setNightMode:(CameraPhotoDeviceNightMode)nightMode
{
    if (_nightMode != nightMode)
    {
        _nightMode = nightMode;
        
//        if (nightMode == CameraPhotoDeviceNightModeAuto || nightMode == CameraPhotoDeviceNightModeOn)
//        {
//            self.exposureDuration = CameraExposureDurationAuto;
//        }
//        else
        {
            self.exposureDuration = CameraExposureDurationClose;
        }
    }
}

- (void)capturePhotoWhenComplete:(void(^)(CMSampleBufferRef sampleBuffer, NSError *error))block
{
    if (photoOutput.connections.count > 0) {
        AVCaptureConnection *connection = [photoOutput.connections objectAtIndex:0];
        NSLog(@"session running: %d, connection enabled: %d, connection active: %d", self.session.running, connection.enabled, connection.active);
        if (self.session.running && connection.enabled && connection.active) {
            [photoOutput captureStillImageAsynchronouslyFromConnection:connection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
                NSLog(@"caputure photo out!");
                block(imageDataSampleBuffer, error);
            }];
            return;
        }
    }
    NSLog(@"capture photo not ok!");
    block(NULL, nil);
}

@end
