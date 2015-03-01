//
//  CameraVideoDevice.m
//
//
//  Created by sky on 13-5-21.
//  Copyright (c) 2013年 DW. All rights reserved.
//

#import "CameraVideoDevice.h"
@import UIKit;

@interface CameraVideoDevice () <AVCaptureVideoDataOutputSampleBufferDelegate>
{
    AVCaptureDevice *inputCamera;
    AVCaptureDeviceInput *videoInput;
    AVCaptureVideoDataOutput *videoOutput;
    
    dispatch_queue_t deviceOperationQueue;
    dispatch_queue_t videoProcessingQueue;

    NSArray *observers;
    NSTimer *videoCheckTimer;
    BOOL videoStreamRunning;
    BOOL cameraConfiguring;
    
    BOOL runningListening;
    BOOL focusListening;
    BOOL receiveVideoFrameNotify;
}

// video encoding
@property (nonatomic, strong) AVAssetWriter *videoWriter;
@property (nonatomic, strong) AVAssetWriterInput *videoWriterInput;
@property (nonatomic, strong) AVAssetWriterInputPixelBufferAdaptor *adaptor;
@end


@implementation CameraVideoDevice

static int frame = -1;

@synthesize delegate = _delegate;
@synthesize session = _session;
@synthesize running = _running;
@synthesize pause = _pause;
@synthesize focustPoint = _focustPoint;
@synthesize exposurePoint = _exposurePoint;
@synthesize exposureDuration = _exposureDuration;
@synthesize flashMode = _flashMode;
@synthesize lowLightBoost = _lowLightBoost;

- (id)initWithSessionPreset:(NSString *)preset cameraPosition:(AVCaptureDevicePosition)position
{
    self = [super init];
    if (!self) {
        return nil;
    }

    deviceOperationQueue = dispatch_queue_create("com.tencent.deviceOperationQueue", NULL);
    videoProcessingQueue = dispatch_queue_create("com.tencent.videoProcessingQueue", NULL);
    
    inputCamera = [self deviceWithType:AVMediaTypeVideo position:position];
    
    self.session = [[AVCaptureSession alloc] init];
    
    [self beginConfiguration];
    
    [self.session setSessionPreset:preset];
    
    NSError *error;
    videoInput = [[AVCaptureDeviceInput alloc] initWithDevice:inputCamera error:&error];
    if ([self.session canAddInput:videoInput]) {
        [self.session addInput:videoInput];
    } else {
        NSLog(@"couldn't add video input");
    }
    
    videoOutput = [[AVCaptureVideoDataOutput alloc] init];
#if !USE_YUV
    [videoOutput setVideoSettings:[NSDictionary dictionaryWithObject:[NSNumber numberWithInt:kCVPixelFormatType_32BGRA] forKey:(id)kCVPixelBufferPixelFormatTypeKey]];
#endif

    NSLog(@"videoOutput settings=%@", videoOutput.videoSettings);
    videoOutput.alwaysDiscardsLateVideoFrames = YES;
    [videoOutput setSampleBufferDelegate:self queue:videoProcessingQueue];
    if ([self.session canAddOutput:videoOutput]) {
        [self.session addOutput:videoOutput];
    } else {
        NSLog(@"couldn't add video output");
    }
    
    // init for video encoding
    {
        [self initVideoAudioWriter];
    }

    [self commitConfiguration];
    
    _exposureDuration = CameraExposureDurationClose;

    self.lowLightBoost = YES;
    
    [self addFocusChangeListener];
    
    [self setupVideoCheckTimer];
    
    return self;
}

- (void)dealloc
{
    [self removeFocusChangeListener];
    [self.session stopRunning];
    [self removeObservers];
    [self.session removeInput:videoInput];
    [self.session removeOutput:videoOutput];
    self.session = nil;
    if (deviceOperationQueue != nil) {
//        dispatch_release(deviceOperationQueue);
        deviceOperationQueue = nil;
    }
    if (videoProcessingQueue != nil) {
//        dispatch_release(videoProcessingQueue);
        videoProcessingQueue = nil;
    }
}

#pragma mark * Getters & Setters *
- (AVCaptureDevicePosition)position
{
    return inputCamera.position;
}
- (void)setPosition:(AVCaptureDevicePosition)position
{
    if (self.position != position) {
        self.pause = YES;
        dispatch_async(deviceOperationQueue, ^{
            [self changeDevicePosition];
            self.pause = NO;
            NSLog(@"<+switch camera end+>");
        });
    }
}
- (void)setFocustPoint:(CGPoint)focustPoint
{
    dispatch_async(deviceOperationQueue, ^{
        if (CGRectContainsPoint(CGRectMake(0, 0, 1, 1), focustPoint)) {
            NSError *error = nil;
            BOOL lockAcquired = [inputCamera lockForConfiguration:&error];
            if (lockAcquired) {
                if (inputCamera.isFocusPointOfInterestSupported && [inputCamera isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
                    inputCamera.focusPointOfInterest = focustPoint;
                    inputCamera.focusMode = AVCaptureFocusModeContinuousAutoFocus;
                    [inputCamera unlockForConfiguration];
                }
            }
        }
    });
}

- (void)setExposurePoint:(CGPoint)exposurePoint
{
    dispatch_async(deviceOperationQueue, ^{
        if (CGRectContainsPoint(CGRectMake(0, 0, 1, 1), exposurePoint)) {
            NSError *error = nil;
            BOOL lockAcquired = [inputCamera lockForConfiguration:&error];
            if (lockAcquired) {
                if (inputCamera.isExposurePointOfInterestSupported && [inputCamera isExposureModeSupported:AVCaptureExposureModeContinuousAutoExposure]) {
                    inputCamera.exposurePointOfInterest = exposurePoint;
                    inputCamera.exposureMode = AVCaptureExposureModeContinuousAutoExposure;
                    [inputCamera unlockForConfiguration];
                }
            }
        }
    });
}

- (void)setExposureDuration:(int32_t)exposureDuration
{
    dispatch_async(deviceOperationQueue, ^{
        if (exposureDuration == _exposureDuration) {
            return;
        }
        _exposureDuration = exposureDuration;
        [self updateDeviceStatus];
    });
}

- (void)setFlashMode:(CameraFlashMode)flashMode
{
    dispatch_async(deviceOperationQueue, ^{
        NSError *err = nil;
        BOOL lockAcquired = [inputCamera lockForConfiguration:&err];
        if (lockAcquired) {
            switch (flashMode) {
                case CameraFlashModeAuto:
                    if(inputCamera.torchMode == AVCaptureTorchModeOn) {
                        inputCamera.torchMode = AVCaptureTorchModeOff;
                    }
                    if (inputCamera.hasFlash && [inputCamera isFlashModeSupported:AVCaptureFlashModeAuto] ) {
                        inputCamera.flashMode = AVCaptureFlashModeAuto;
                    }
                    break;
                case CameraFlashModeOff:
                    if(inputCamera.torchMode == AVCaptureTorchModeOn) {
                        inputCamera.torchMode = AVCaptureTorchModeOff;
                    }
                    if (inputCamera.hasFlash && [inputCamera isFlashModeSupported:AVCaptureFlashModeOff] ) {
                        inputCamera.flashMode = AVCaptureFlashModeOff;
                    }
                    break;
                case CameraFlashModeOn:
                    if(inputCamera.torchMode == AVCaptureTorchModeOn) {
                        inputCamera.torchMode = AVCaptureTorchModeOff;
                    }
                    if (inputCamera.hasFlash && [inputCamera isFlashModeSupported:AVCaptureFlashModeOn] ) {
                        inputCamera.flashMode = AVCaptureFlashModeOn;
                    }
                    break;
                case CameraFlashModeLight:
                    if (inputCamera.hasFlash && [inputCamera isTorchModeSupported:AVCaptureTorchModeOn]) {
                        inputCamera.torchMode = AVCaptureTorchModeOn;
                    }
                    if (inputCamera.hasFlash && [inputCamera isFlashModeSupported:AVCaptureFlashModeOff] ) {
                        inputCamera.flashMode = AVCaptureFlashModeOff;
                    }
                    break;
                default:
                    break;
            }
            _flashMode = flashMode;
            [inputCamera unlockForConfiguration];
        } else {
            NSLog(@"CANNOT SET CAMERA FALSH, DEVICE ERROR!");
        }
    });
}
- (void)setLowLightBoost:(BOOL)lowLightBoost
{
    dispatch_async(deviceOperationQueue, ^{
        _lowLightBoost = lowLightBoost;
        NSError *error = nil;
        [videoInput.device lockForConfiguration:&error];
        if ([videoInput.device respondsToSelector:@selector(isLowLightBoostSupported)] && videoInput.device.isLowLightBoostSupported) {
            videoInput.device.automaticallyEnablesLowLightBoostWhenAvailable = lowLightBoost;
        }
        [videoInput.device unlockForConfiguration];
    });
}

- (BOOL)hasFlash
{
    return inputCamera.hasFlash;
}

- (BOOL)hasFront
{
    return [UIImagePickerController isCameraDeviceAvailable:UIImagePickerControllerCameraDeviceFront];
}

#pragma mark * Interface Methods *
+ (BOOL)deviceDenied
{
    if ([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)] ) {
        return [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo] == AVAuthorizationStatusDenied;
    }
    return NO;
}
- (void)startDevice
{
    dispatch_async(deviceOperationQueue, ^{
        CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
        @try {
            @synchronized(self){
                [self.session startRunning];
            }
        }
        @catch (NSException *exception) {
        }
        @finally {
            NSLog(@"Camera start completed");
            _running = YES;
            [self.delegate cameraDeviceEvent:CameraDeviceEvent_Started withAguments:nil];
            time = CFAbsoluteTimeGetCurrent() - time;
            NSLog(@"Camera startRunning cost: %lf", time);
        }
    });
    [self removeRunningChangeListener];
    [self addRunningChangeListener];
}

- (void)stopDevice
{
    _running = NO;
    
    dispatch_async(deviceOperationQueue, ^{
        CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
        @try {
            [self.session stopRunning];
        }
        @catch (NSException *exception) {
            [self.session stopRunning];
        }
        @finally {
            [self.delegate cameraDeviceEvent:CameraDeviceEvent_Stopped withAguments:nil];
//            time = CFAbsoluteTimeGetCurrent() - time;
//            NSLog(@"Camera stopRunning cost: %lf", time);
//            
//            [_videoWriterInput markAsFinished];
//            [_videoWriter finishWritingWithCompletionHandler:^{
//                DLog(@"finished recording");
//                NSString *parentDir = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Movie"];
//                NSString *betaCompressionDirectory = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Movie_llu.m4v"];
//                
//                betaCompressionDirectory = [parentDir stringByAppendingString:[NSString stringWithFormat:@"_%f.m4v", [[NSDate date] timeIntervalSince1970]]];
//                betaCompressionDirectory = [parentDir stringByAppendingString:@".m4v"];
//                UISaveVideoAtPathToSavedPhotosAlbum(betaCompressionDirectory, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
//                frame = 0;
//            }];
        }
    });
    
    [self removeRunningChangeListener];
    [self removeFocusChangeListener];
}

- (void)startRecording {
    frame = 0;
}

- (void)stopRecording {
    if (frame > 0) {
        frame = -2;
        [_videoWriterInput markAsFinished];
        [_videoWriter finishWritingWithCompletionHandler:^{
            NSLog(@"finished recording");
            NSString *parentDir = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Movie"];
            NSString *betaCompressionDirectory = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Movie_llu.m4v"];
            
//            betaCompressionDirectory = [parentDir stringByAppendingString:[NSString stringWithFormat:@"_%f.m4v", [[NSDate date] timeIntervalSince1970]]];
//            betaCompressionDirectory = [parentDir stringByAppendingString:@".m4v"];
            UISaveVideoAtPathToSavedPhotosAlbum(betaCompressionDirectory, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
            frame = -1;
        }];
    }
}

- (void)video:(NSData *)video didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo
{
    NSLog(@"save video finish.error=%@", error);
}

- (void)beginConfiguration
{
    cameraConfiguring = YES;
    [self.session beginConfiguration];
}
- (void)commitConfiguration
{
    [self.session commitConfiguration];
    cameraConfiguring = NO;
}
#pragma mark * Internal Methods *
- (void)restartDevcie
{
    dispatch_async(deviceOperationQueue, ^{
        if (cameraConfiguring != YES) {
            CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
            
            @synchronized(self){
                NSError *error = nil;
                [inputCamera lockForConfiguration:&error];
                 [self.session stopRunning];
                 [self.session startRunning];
                 [inputCamera unlockForConfiguration];
            }
            [self.delegate cameraDeviceEvent:CameraDeviceEvent_Restarted withAguments:nil];
            time = CFAbsoluteTimeGetCurrent() - time;
            NSLog(@"restartCapture cost: %lf", time);
        }
    });
}

- (AVCaptureDevice *)deviceWithType:(NSString *)type position:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
	for (AVCaptureDevice *device in devices)
	{
        if (device.position == position) {
            return device;
        }
	}
    return nil;
}
- (void)changeDevicePosition
{
    CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
    BOOL success = NO;
    NSError *error;
    AVCaptureDeviceInput *newVideoInput;
    AVCaptureDevicePosition currentCameraPosition = videoInput.device.position;
    
    if(currentCameraPosition == AVCaptureDevicePositionBack) {
        currentCameraPosition = AVCaptureDevicePositionFront;
    } else {
        currentCameraPosition = AVCaptureDevicePositionBack;
    }
    
    AVCaptureDevice *backFacingCamera = [self deviceWithType:AVMediaTypeVideo position:currentCameraPosition];
    newVideoInput = [[AVCaptureDeviceInput alloc] initWithDevice:backFacingCamera error:&error];
    
    NSLog(@"GPUImageVideoCamera init errorcode=%ld, domain=%@", (long)error.code, error.domain);
    
    if (newVideoInput != nil)
    {
        @try {
            [self beginConfiguration];
            [self.session removeInput:videoInput];
            if ([self.session canAddInput:newVideoInput]) {
                [self.session addInput:newVideoInput];
                videoInput = newVideoInput;
                inputCamera = backFacingCamera;
                success = YES;
            } else {
                NSLog(@"GPUImageVideoCamera can't AddInput");
                dispatch_async(deviceOperationQueue, ^{
                    [self changeDevicePosition];
                });
            }
        }
        @catch (NSException *exception) {
            [self.session addInput:videoInput];
        }
        @finally {
            [self commitConfiguration];
        }
    }
    
    if (success) {
        if (self.exposureDuration != CameraExposureDurationClose) {
            [self updateDeviceStatus];
        } else {
            self.lowLightBoost = YES;
        }
        [self.delegate cameraDeviceEvent:CameraDeviceEvent_PositionChanged withAguments:nil];
    }

    NSLog(@"changeDevicePosition: %lf", CFAbsoluteTimeGetCurrent() - start);
}

- (void)updateDeviceStatus
{
    CFAbsoluteTime time = CFAbsoluteTimeGetCurrent();
    
    int32_t minDuration = 1;
    int32_t maxDuration ;
    if (self.position == AVCaptureDevicePositionFront) {
        minDuration = 2;
        maxDuration = 2;
    }
    if (self.exposureDuration == CameraExposureDurationClose) {
        self.lowLightBoost = YES;
        minDuration = 20;
        maxDuration = 15;
    } else {
        self.lowLightBoost = NO;
        if (self.exposureDuration == CameraExposureDurationBeauty) {
            minDuration = 8;
            maxDuration = 4;
        } else if (self.exposureDuration == 0) {
            minDuration = 20;
            maxDuration = 2;
        } else {
            minDuration = MAX(minDuration, self.exposureDuration);
            maxDuration = minDuration;
        }
    }
    if (/* DISABLES CODE */ (1)){//[self.session isRunning]) {
        AVCaptureConnection *connection = [videoOutput connectionWithMediaType:AVMediaTypeVideo];
        connection.videoMinFrameDuration = CMTimeMake(1, minDuration);
        connection.videoMaxFrameDuration = CMTimeMake(1, maxDuration);
        self.flashMode = self.flashMode;
    } else {
        NSLog(@"set expsoure duration: session not running");
    }
    NSLog(@"epxosureDuration cost time: %lf", CFAbsoluteTimeGetCurrent() - time);
}

-(void) initVideoAudioWriter

{
    
    CGSize size = CGSizeMake(960, 640);

    NSString *parentDir = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Movie1233"];
    NSString *betaCompressionDirectory = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Movie_llu.m4v"];
    
    betaCompressionDirectory = [parentDir stringByAppendingString:[NSString stringWithFormat:@"_%f.m4v", [[NSDate date] timeIntervalSince1970]]];
    betaCompressionDirectory = [parentDir stringByAppendingString:@".m4v"];
//    [[[paths objectAtIndex:0] stringByAppendingPathComponent:[NSString stringWithFormat:@"%llu.m4v",mach_absolute_time()]] retain]
    NSError *error = nil;
    
    
    
    unlink([betaCompressionDirectory UTF8String]);
    
    
    
    //----initialize compression engine
    
    self.videoWriter = [[AVAssetWriter alloc] initWithURL:[NSURL fileURLWithPath:betaCompressionDirectory] fileType:AVFileTypeQuickTimeMovie error:&error];
    
//    NSParameterAssert(videoWriter);
    
    if(error)
        
        NSLog(@"error = %@", [error localizedDescription]);
    
    NSDictionary *videoCompressionProps = [NSDictionary dictionaryWithObjectsAndKeys:
                                           
                                           [NSNumber numberWithDouble:1280.0*1024.0],AVVideoAverageBitRateKey,
                                           
                                           nil ];
    
    
    
    NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:AVVideoCodecH264, AVVideoCodecKey,
                                   
                                   [NSNumber numberWithInt:size.width], AVVideoWidthKey,
                                   
                                   [NSNumber numberWithInt:size.height],AVVideoHeightKey,videoCompressionProps, AVVideoCompressionPropertiesKey, nil];
    
    self.videoWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    
    
    
//    NSParameterAssert(videoWriterInput);
    
    
    
    _videoWriterInput.expectsMediaDataInRealTime = YES;
    
    
    
    NSDictionary *sourcePixelBufferAttributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:
                                                           
                                                           [NSNumber numberWithInt:kCVPixelFormatType_32ARGB], kCVPixelBufferPixelFormatTypeKey, nil];
    
    
    
    self.adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:_videoWriterInput sourcePixelBufferAttributes:sourcePixelBufferAttributesDictionary];
    
    NSParameterAssert(_videoWriterInput);
    
//    NSParameterAssert([_videoWriter canAddInput:videoWriterInput]);
    
    
    
    if ([_videoWriter canAddInput:_videoWriterInput])
        
        NSLog(@"I can add this input");
    
    else
        
        NSLog(@"i can't add this input");
    
    
    
    // Add the audio input
    
//    AudioChannelLayout acl;
//    
//    bzero( &acl, sizeof(acl));
//    
//    acl.mChannelLayoutTag = kAudioChannelLayoutTag_Mono;
    
    
    
//    NSDictionary* audioOutputSettings = nil;
    
    //    audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
    
    //                           [ NSNumber numberWithInt: kAudioFormatAppleLossless ], AVFormatIDKey,
    
    //                           [ NSNumber numberWithInt: 16 ], AVEncoderBitDepthHintKey,
    
    //                           [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
    
    //                           [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
    
    //                           [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
    
    //                           nil ];
    
//    audioOutputSettings = [ NSDictionary dictionaryWithObjectsAndKeys:
//                           
//                           [ NSNumber numberWithInt: kAudioFormatMPEG4AAC ], AVFormatIDKey,
//                           
//                           [ NSNumber numberWithInt:64000], AVEncoderBitRateKey,
//                           
//                           [ NSNumber numberWithFloat: 44100.0 ], AVSampleRateKey,
//                           
//                           [ NSNumber numberWithInt: 1 ], AVNumberOfChannelsKey,
//                           
//                           [ NSData dataWithBytes: &acl length: sizeof( acl ) ], AVChannelLayoutKey,
//                           
//                           nil ];
    
    
    
//    audioWriterInput = [[AVAssetWriterInput
//                         
//                         assetWriterInputWithMediaType: AVMediaTypeAudio
//                         
//                         outputSettings: audioOutputSettings ] retain];
//    
//    
//    
//    audioWriterInput.expectsMediaDataInRealTime = YES;
//    
//    // add input
//    
//    [videoWriter addInput:audioWriterInput];
    
    [_videoWriter addInput:_videoWriterInput];
    
}

- (void)setupVideoCheckTimer
{
    videoCheckTimer = [NSTimer scheduledTimerWithTimeInterval:4.0
                                                       target:self
                                                     selector:@selector(videoCheckTimerHandler)
                                                     userInfo:nil
                                                      repeats:YES];
}

- (void)videoCheckTimerHandler
{
    videoCheckTimer = nil;
    if ([self.session isRunning] && self.pause != YES) {
        if (videoStreamRunning != YES && self.exposureDuration == CameraExposureDurationClose) {
            NSLog(@"can not receive video data");
            [self restartDevcie];
        }
        videoStreamRunning = NO;
    }
}

- (void)addRunningChangeListener
{
    if (runningListening == NO) {
        NSLog(@"addRunningChangeListener");
        [self.session addObserver:self forKeyPath:@"running" options:NSKeyValueObservingOptionNew context:nil];
        runningListening = YES;
    }
}

- (void)removeRunningChangeListener
{
    if (runningListening == YES) {
        NSLog(@"removeRunningChangeListener");
        [self.session removeObserver:self forKeyPath:@"running"];
        runningListening = NO;
    }
}

- (void)addFocusChangeListener
{
    if (focusListening == NO && inputCamera.position == AVCaptureDevicePositionBack) {
        NSLog(@"addFocusChangeListener");
        [inputCamera addObserver:self forKeyPath:@"adjustingFocus" options:NSKeyValueObservingOptionNew context:nil];
        focusListening = YES;
    }
}

- (void)removeFocusChangeListener
{
    if (focusListening == YES && inputCamera.position == AVCaptureDevicePositionBack) {
        NSLog(@"removeFocusChangeListener");
        [inputCamera removeObserver:self forKeyPath:@"adjustingFocus"];
        focusListening = NO;
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"running"]) {
        NSLog(@"camera device running changed!");
        BOOL running = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        NSLog(@"camera isrunning has change to %d %d",running, self.session.isInterrupted);
        if (running){
            receiveVideoFrameNotify = NO;
        } else if(!self.session.isInterrupted) {
            NSLog(@"-----------------------camera stop, restart it--------------------------");
        }
    } else if ([keyPath isEqualToString:@"adjustingFocus"]) {
        BOOL adjustingFocus = [[change objectForKey:NSKeyValueChangeNewKey] isEqualToNumber:[NSNumber numberWithInt:1]];
        CameraDeviceEvent event = adjustingFocus ? CameraDeviceEvent_FocusBegan : CameraDeviceEvent_FocusEnded;
        NSDictionary *args = @{@"x": @(inputCamera.focusPointOfInterest.x), @"y": @(inputCamera.focusPointOfInterest.y)};
        [self.delegate cameraDeviceEvent:event withAguments:args];
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    if (self.pause || self.running != YES) {
        return;
    }
    videoStreamRunning = YES;
    AVCaptureInputPort *inputPort = [connection.inputPorts objectAtIndex:0];
    AVCaptureDeviceInput *input = (AVCaptureDeviceInput *)inputPort.input;
    AVCaptureDevicePosition inputPos = input.device.position;
    
    if (!receiveVideoFrameNotify) {
        receiveVideoFrameNotify = YES;
        [self.delegate cameraDeviceEvent:CameraDeviceEvent_FrameStarted withAguments:nil];
    }
    if (inputPos == AVCaptureDevicePositionUnspecified) {
        NSLog(@"captureOutput, camera position unspecified, drop it!!!!");
        return;
    }
    NSDictionary *args = @{@"buffer": @((NSInteger)sampleBuffer), @"position": @(inputPos)};
    [self.delegate cameraDeviceEvent:CameraDeviceEvent_FrameReceived withAguments:args];
    
    @autoreleasepool {
        
        CMTime lastSampleTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
        
        if( frame == 0 && _videoWriter.status != AVAssetWriterStatusWriting) {
            [_videoWriter startWriting];
            [_videoWriter startSessionAtSourceTime:lastSampleTime];
        }
        
        if (frame >= 0) {
            if (captureOutput == videoOutput) {
                if(_videoWriter.status > AVAssetWriterStatusWriting) {
                    NSLog(@"Warning: writer status is %zd", _videoWriter.status);
                    if( _videoWriter.status == AVAssetWriterStatusFailed) {
                        NSLog(@"Error: %@", _videoWriter.error);
                    }
                    return;
                }
                
                if ([_videoWriterInput isReadyForMoreMediaData]) {
                    if(![_videoWriterInput appendSampleBuffer:sampleBuffer]) {
                        NSLog(@"Unable to write to video input");
                    } else {
                        NSLog(@"already write vidio");
                    }
                }
            }
            frame ++;
        }
    }
}

- (void)captureOutput:(AVCaptureOutput *)captureOutput didDropSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
}

- (void)addObservers
{
#if 0
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    id runtimeErrorObserver = [notificationCenter addObserverForName:AVCaptureSessionRuntimeErrorNotification
                                                              object:self.session
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification *note) {
                                                              dispatch_async(dispatch_get_main_queue(), ^(void) {
                                                                  NSLog(@"====>runtimeError %@",
                                                                        [[note userInfo] objectForKey:AVCaptureSessionErrorKey]);
                                                              });
                                                          }];
    id didStartRunningObserver = [notificationCenter addObserverForName:AVCaptureSessionDidStartRunningNotification
                                                                 object:self.session
                                                                  queue:[NSOperationQueue mainQueue]
                                                             usingBlock:^(NSNotification *note) {
                                                                 NSLog(@"====>did start running");
                                                             }];
    id didStopRunningObserver = [notificationCenter addObserverForName:AVCaptureSessionDidStopRunningNotification
                                                                object:self.session
                                                                 queue:[NSOperationQueue mainQueue]
                                                            usingBlock:^(NSNotification *note) {
                                                                NSLog(@"====>did stop running");
                                                            }];
    id deviceWasConnectedObserver = [notificationCenter addObserverForName:AVCaptureDeviceWasConnectedNotification
                                                                    object:nil
                                                                     queue:[NSOperationQueue mainQueue]
                                                                usingBlock:^(NSNotification *note) {
                                                                    NSLog(@"====>did ConnectedObserver ");
                                                                }];
    id deviceWasDisconnectedObserver = [notificationCenter addObserverForName:AVCaptureDeviceWasDisconnectedNotification
                                                                       object:nil
                                                                        queue:[NSOperationQueue mainQueue]
                                                                   usingBlock:^(NSNotification *note) {
                                                                       NSLog(@"====>did disConnectedObserver ");
                                                                   }];
    observers = [[NSArray alloc] initWithObjects:runtimeErrorObserver, didStartRunningObserver, didStopRunningObserver, deviceWasConnectedObserver, deviceWasDisconnectedObserver, nil];
#endif
}

- (void)removeObservers
{
#if 0
    NSNotificationCenter *notificationCenter = [NSNotificationCenter defaultCenter];
    for (id observer in observers) {
        [notificationCenter removeObserver:observer];
    }
    [observers release];
#endif
}


@end
