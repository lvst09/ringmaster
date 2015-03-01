//
//  CameraController.m
//  
//
//  Created by sky on 13-5-22.
//  Copyright (c) 2013年 DW. All rights reserved.
//

#import <ImageIO/ImageIO.h>
#import <FilterEngine/GPUImageOpenGLESContext.h>
#import <FilterEngine/FilterEnum.h>
#import <FilterEngine/UIImageOrientationFilter.h>
#import <FilterEngine/CPUImageFilter.h>
#import <FilterEngine/GPUImageFilter.h>
#import <FilterEngine/GPUImageView.h>
#import <FilterEngine/FilterFactory.h>
#import <FilterEngine/UIImageUtils.h>
#import <FilterEngine/GPUImagePicture.h>
#import <FilterEngine/FilterEngine.h>
#import "CameraController.h"
#import "CameraPhotoDevice.h"

@interface CameraController () <CameraVideoDeviceDelegate, CPUImageFilterDelegate>
{
    CameraPhotoDevice *device;
    
    CPUImageFilter *cpuFilter;
    
    NSMutableArray *delegateStack;
    
    NSMutableArray *multiSnapshots;
    NSInteger snapshots;
    
    CIDetector *faceDetector;
    UIImage *faceBounds;
}

@property (nonatomic, assign) NSObject<CameraControllerDelegate> *listener;
@property (nonatomic, retain) UIImageOrientationFilter *rotationFilter;
@property (nonatomic, retain) GPUImageFilter *exposureFilter;
@property (nonatomic, retain) GPUImageFilter *filter;
@property (nonatomic, retain) GPUImageView *preview;
@property (nonatomic, retain) UIImage *originImage;

@end

static CameraController *controller = nil;

@implementation CameraController

@synthesize listener = _listener;
@synthesize filterIndex = _filterIndex;
@synthesize faceMonitoringEnabled = _faceMonitoringEnabled;
@synthesize notifyNextFrame = _notifyNextFrame;
@synthesize cameraOrientation = _cameraOrientation;

@synthesize rotationFilter = _rotationFilter;
@synthesize exposureFilter = _exposureFilter;
@synthesize filter = _filter;
@synthesize preview = _preview;


- (id)init
{
    self = [super init];
    if (self) {
        device.delegate = self;
        delegateStack = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [delegateStack removeAllObjects]; [delegateStack release];
    [super dealloc];
}

- (BOOL)supportFlash
{
    return device.hasFlash;
}

- (BOOL)supportFront
{
    return device.hasFront;
}

- (AVCaptureDevicePosition)devicePosition
{
    return device.position;
}

- (void)setDevicePosition:(AVCaptureDevicePosition)devicePosition
{
    if (devicePosition == AVCaptureDevicePositionFront && controller.supportFront != YES) {
        LOG_D(@"current device not support front camera!");
        return;
    }
    device.position = devicePosition;
}

- (BOOL)devicePaused
{
    return device.pause;
}
- (void)setDevicePaused:(BOOL)devicePaused
{
    LOG_D(@"CameraController.devicePaused: %d", devicePaused);
    device.pause = devicePaused;
}
- (BOOL)running
{
    return device.running;
}

- (CameraFlashMode)flashMode
{
    return device.flashMode;
}
- (void)setFlashMode:(CameraFlashMode)flashMode
{
    device.flashMode = flashMode;
}

- (CGPoint)focusPoint
{
    return [self unTransformAVCaptureDevicePoint:device.focustPoint];
}
- (void)setFocusPoint:(CGPoint)focusPoint
{
    CGPoint ptDevice = [self transformAVCaptureDevicePoint:focusPoint];
    device.focustPoint = ptDevice;
}

- (CGPoint)exposurePoint
{
    return [self unTransformAVCaptureDevicePoint:device.exposurePoint];
}
- (void)setExposurePoint:(CGPoint)exposurePoint
{
    CGPoint ptDevice = [self transformAVCaptureDevicePoint:exposurePoint];
    device.exposurePoint = ptDevice;
}
- (CGFloat)exposureLevel
{
    __block CGFloat level = 0;
    [FilterFactory runBlockInFilterQueueSync:^{
        level = [[self.exposureFilter getProperty:@"level"] floatValue];
    }];
    return level;
}
- (void)setExposureLevel:(CGFloat)exposureLevel
{
    [FilterFactory runBlockInFilterQueueSync:^{
        [self.exposureFilter setProperty:@"level" value:[NSNumber numberWithFloat:exposureLevel]];
    }];
}
- (NSInteger)exposureDuration
{
    return device.exposureDuration;
}
- (void)setExposureDuration:(NSInteger)exposureDuration
{
    device.exposureDuration = exposureDuration;
}
- (void)setFilterIndex:(NSInteger)filterIndex
{
    _filterIndex = filterIndex;
//    NSInteger preview = [self.filterManager previewOfFilterAtIndex:filterIndex];
//    if (filterIndex != MRFilterNone) {
        [self switchGPUFilter:0];
//    }else{
//        [self switchGPUFilter:preview];
//    }
}

- (void)setFaceMonitoringEnabled:(BOOL)faceMonitoringEnabled
{
    if (_faceMonitoringEnabled == YES && faceMonitoringEnabled != YES) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self drawFaceBoxesForFeatures:[NSArray array] forVideoBox:CGRectZero orientation:UIDeviceOrientationPortrait];
        });
    }
    _faceMonitoringEnabled = faceMonitoringEnabled;
}
- (void)setCameraOrientation:(BOOL)cameraOrientation
{
    _cameraOrientation = cameraOrientation;
    self.filter.textureOrientation = cameraOrientation;
}

- (NSObject<CameraControllerDelegate> *)listener
{
    if (delegateStack.count > 0) {
        return [delegateStack lastObject];
    }
    return nil;
}

//- (MRFilterManager *)filterManager
//{
//    if (_filterManager) {
//        return _filterManager;
//    }
//    _filterManager = [MRFilterManager defaultManager];
//    return _filterManager;
//}

+ (CameraController *)shareController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        controller = [[CameraController alloc] init];
    });
    return controller;
}
+ (BOOL)checkCameraAuthorization
{
    // 先判断是否访问限制：“通用-访问控制-相机”
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        NSString *title = nil;
        // Please trun on the "General-Restrictions-Camera" privacy in your iPhone.
        NSString *message = NSLocalizedString(@"GeneralRestrictionsMessage", nil);
        UIAlertView *alert = [[UIAlertView alloc] initTitle:title message:message delegate:self cancelButtonTitle:NSLocalizedString(@"确定", nil) otherButtonTitles:nil];
        [alert show];
        [alert release];
        return YES;
    }
    if ([CameraVideoDevice deviceDenied]) {
        NSString *title = NSLocalizedString(@"cameraAuthTitle", nil);
        NSString *message = NSLocalizedString(@"cameraAuthDescription", nil);
        NSString *cancel = NSLocalizedString(@"cameraTipButton", nil);
        UIAlertView *alert = [[UIAlertView alloc] initTitle:title message:message delegate:self cancelButtonTitle:cancel otherButtonTitles:nil];
        [alert show];
        [alert release];
        return YES;
    }
    return NO;
}
+ (void)prestartCamera
{
    CameraController *controller = [CameraController shareController];
    [controller startCamera];
}
- (void)startCamera
{
    [device startDevice];
}
- (void)stopCamera
{
    [device stopDevice];
}
- (void)rotateCamera
{
    if (self.devicePosition == AVCaptureDevicePositionFront) {
        self.devicePosition = AVCaptureDevicePositionBack;
    } else {
        self.devicePosition = AVCaptureDevicePositionFront;
    }
}
- (void)takePhotoWithOrientation:(MRCamera_Orientation)orientation andZoom:(CGFloat)zoom
{
    if ([self isMultiInputFilter]) {
        [self burstPhotos:7];
        return;
    }
    LOG_METHOD;
    [device capturePhotoWhenComplete:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        @autoreleasepool {
            [self.listener cameraControllerEvent:CameraControllerEvent_CaptureBegan withArgs:nil];
            if (imageDataSampleBuffer == nil) {
                LOG_E(@"capture still image failed! %@", error);
                [self.listener cameraControllerEvent:CameraControllerEvent_CaptureError withArgs:nil];
                return;
            }
            self.devicePaused = YES;
            DBG_D(CFAbsoluteTime begin = CFAbsoluteTimeGetCurrent();)
            
            NSData *dataForRawBytes = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
            UIImage *stillImage = [UIImage imageWithData:dataForRawBytes];
            
            [self.listener cameraAttachmentMetadata:imageDataSampleBuffer];
            LOG_D(@"captured still image width: %f, height: %f, cost time: %lf", stillImage.size.width, stillImage.size.height, CFAbsoluteTimeGetCurrent() - begin);
            
            // flip the image
//            if (controller.filterIndex == MRFilterNone) {
//                if (zoom > 1.0) {
//                    UIImage *zoomScale = [self zoomPhoto:stillImage withZoom:zoom needScale:YES];
//                    zoomScale = [self filteredImageFromImage:zoomScale exposureOnly:NO];
//                    [self.listener cameraControllerEvent:CameraControllerEvent_CaptureEnded withArgs:@{@"preview": zoomScale, @"save": zoomScale}];
//                } else if (self.exposureLevel != 0) {
//                    if (self.devicePosition == AVCaptureDevicePositionFront) {
//                        stillImage = [UIImageUtils horizontalMirrorImage:stillImage];
//                    }
//                    NSArray *images = [[NSArray alloc] initWithObjects:stillImage, nil];
//                    [self applyFilter:MIC_CPUEXPOSURE withImages:images deviceOrientation:orientation];
//                    [images release];
//                } else {
//                    if (self.devicePosition == AVCaptureDevicePositionFront) {
//                        stillImage = [UIImageUtils horizontalMirrorImage:stillImage];
//                    }
//                    NSObject *save = stillImage;
//                    if (self.devicePosition != AVCaptureDevicePositionFront) {
//                        save = dataForRawBytes;
//                    }
//                    [self.listener cameraControllerEvent:CameraControllerEvent_CaptureEnded withArgs:@{@"preview": [self currentImageFromFilter:self.filter], @"save": save, @"image" : stillImage,}];
//                }
//            } else {
                DBG_D(CFAbsoluteTime s = CFAbsoluteTimeGetCurrent();)
                if (zoom > 1.0f) {
                    self.originImage = [self zoomPhoto:stillImage withZoom:zoom needScale:YES];
                } else {
                    // scale the image
                    UIImage *scaledImage = [UIImageUtils scaleImage:stillImage toSize:CGSizeMake(640, 852)];
#if 1 // for optimize
                    if ([self hasDifferentSaveFilter:controller.filterIndex] == NO) {
                        UIImage *processed = [self filteredImageFromImage:scaledImage exposureOnly:NO];
                        [self.listener cameraControllerEvent:CameraControllerEvent_CaptureEnded withArgs:@{@"preview": processed, @"save": processed}];
                        return;
                    }
#endif
                    self.originImage = scaledImage;
                }
                LOG_D(@"scale still image to width: %f, height: %f, cost: %lf", self.originImage.size.width, self.originImage.size.height, CFAbsoluteTimeGetCurrent() - s);
                if (self.exposureLevel != 0) {
                    self.originImage = [self filteredImageFromImage:self.originImage exposureOnly:YES];
                } else if (self.devicePosition == AVCaptureDevicePositionFront) {
                    self.originImage = [UIImageUtils horizontalMirrorImage:self.originImage];
                }
            NSInteger filterId = 0;//[self.filterManager finalOfFilterAtIndex:controller.filterIndex andUseForFront:self.devicePosition == AVCaptureDevicePositionFront];
                
                NSArray *images = [[NSArray alloc] initWithObjects:self.originImage, nil];
                [self applyFilter:filterId withImages:images deviceOrientation:orientation];
                [images release];
//            }
            LOG_D(@"captureStillImage completer cost: %lf", CFAbsoluteTimeGetCurrent() - begin);
        }
    }];
}
- (void)burstPhotos:(NSInteger)count
{
    LOG_METHOD;
    snapshots = count;
}

- (void)pushDelegate:(NSObject<CameraControllerDelegate> *)delegate
{
    [delegateStack addObject:delegate];
    self.preview = [delegate imageViewOfDelegate];
    [FilterFactory runBlockInFilterQueueSync:^{
        [self.filter removeAllTargets];
        [self.filter addTarget:self.preview];
    }];
}
- (NSObject<CameraControllerDelegate> *)popDelegate
{
    NSObject<CameraControllerDelegate> *delegate = nil;
    self.preview = nil;
    if (delegateStack.count > 0) {
        delegate = [delegateStack lastObject];
        [delegateStack removeObject:delegate];
    }
    if (delegateStack.count > 0) {
        NSObject<CameraControllerDelegate> *del = [delegateStack lastObject];
        self.preview = [del imageViewOfDelegate];
    }
    [FilterFactory runBlockInFilterQueueSync:^{
        [self.filter removeAllTargets];
        [self.filter addTarget:self.preview];
    }];
    return delegate;
}
- (NSObject<CameraControllerDelegate> *)currentDelegate
{
    if (delegateStack.count > 0) {
        NSObject<CameraControllerDelegate> *del = [delegateStack lastObject];
        return del;
    }
    return nil;
}

- (void)clearVideoFrame
{
    [FilterFactory runBlockInFilterQueueSync:^{
        [self.preview clearVideo];
    }];
}
- (void)addImageView:(GPUImageView *)imageView
{
    [FilterFactory runBlockInFilterQueueSync:^{
        [self.filter removeAllTargets];
        [self.filter addTarget:imageView];
    }];
    self.preview = imageView;
}

#pragma mark * Internal Methods *
- (void)processFrameBuffer:(CMSampleBufferRef)buffer withPosition:(AVCaptureDevicePosition)position
{
    [FilterFactory runBlockInFilterQueueSync: ^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        if (self.exposureFilter == nil) {
            [self setupFilterEnv];
        }
        
        if (self.notifyNextFrame) {
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
            [self.listener cameraControllerEvent:CameraControllerEvent_VideoReceived withArgs:nil];
            controller.filterIndex = controller.filterIndex;
            self.notifyNextFrame = NO;
        }
        
        CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(buffer);
        
        CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(buffer);
        
        [self.rotationFilter setOrientationMode:UIImageOrientationRight];
        [self.rotationFilter setFlipMode:self.devicePosition != AVCaptureDevicePositionFront ? UIImageFlipNone : UIImageFlipHorizontal];
#if USE_YUV
        [self.rotationFilter setInputPixelBuffer:pixelBuffer withFormat:UIImageFormat420V];
#else
        [self.rotationFilter setInputPixelBuffer:pixelBuffer withFormat:UIImageFormatRGBA];
#endif
        
        [self.filter setWidth:[self.rotationFilter getOutputSize].width andHeight:[self.rotationFilter getOutputSize].height];
        [self.rotationFilter newFrameReadyAtTime:currentTime];
        
        if (snapshots > 0) {
            [self.listener cameraAttachmentMetadata:buffer];
            [self snapshotVideoStream:[self.filter imageFromCurrentlyProcessedOutput]];
        }
        
        if (self.faceMonitoringEnabled) {
            [self detectFace:buffer];
        }
    }];
}

- (void)snapshotVideoStream:(UIImage *)image
{
    snapshots--;
    if (multiSnapshots == nil) {
        multiSnapshots = [[NSMutableArray alloc] init];
    }
    [multiSnapshots addObject:image];
    
    if (snapshots == 0) {
        self.originImage = [multiSnapshots objectAtIndex:multiSnapshots.count / 2 + 1];
        int finalFilterId = 0;//[self.filterManager finalOfFilterAtIndex:controller.filterIndex andUseForFront:self.devicePosition == AVCaptureDevicePositionFront];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.listener cameraControllerEvent:CameraControllerEvent_CaptureBegan withArgs:nil];
        });
        [self applyFilter:finalFilterId withImages:multiSnapshots deviceOrientation:MRCamera_Orientation_Up];
        [multiSnapshots release];
        multiSnapshots = nil;
        self.devicePaused = YES;
//
//        [device capturePhotoWhenComplete:^(CMSampleBufferRef sampleBuffer, NSError *error) {
//        }];
    }
}

- (void)setupFilterEnv
{
    [GPUImageOpenGLESContext useImageProcessingContext];
    self.rotationFilter = (UIImageOrientationFilter *)[FilterFactory createGPUFilter:MIC_ORIENTATION];
    self.exposureFilter = [FilterFactory createGPUFilter:MIC_EXPOSURE];
    if (self.filter == nil) {
        self.filter = [FilterFactory createGPUFilter:MIC_LENS];
    } else {
        [self.filter removeAllTargets];
    }
    [self.rotationFilter addTarget:self.exposureFilter];
    [self.exposureFilter addTarget:self.filter];
    [self.filter addTarget:self.preview];
}

- (UIImage *)currentImageFromFilter:(GPUImageFilter *)filter
{
    __block UIImage *image = nil;
    [FilterFactory runBlockInFilterQueueSync:^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        image = [[filter imageFromCurrentlyProcessedOutput] retain];
    }];
    return [image autorelease];
}

- (UIImage *)filteredImageFromImage:(UIImage *)image exposureOnly:(BOOL)exposureOnly
{
    __block UIImage *filtered = nil;
    [FilterFactory runBlockInFilterQueueSync: ^{
        CMTime time = {0};
        [GPUImageOpenGLESContext useImageProcessingContext];
        [self.filter removeTarget:self.preview];

        [self.rotationFilter setOrientationMode:image.imageOrientation];
        [self.rotationFilter setFlipMode:self.devicePosition != AVCaptureDevicePositionFront ? UIImageFlipNone : UIImageFlipHorizontal];

        [self.filter setWidth:image.size.width andHeight:image.size.height];
        [self.rotationFilter setInputSize:CGSizeMake(CGImageGetWidth(image.CGImage), CGImageGetHeight(image.CGImage))];
        [self.rotationFilter setInputImage:image];
        [self.rotationFilter newFrameReadyAtTime:time];
        if (exposureOnly) {
            filtered = [self.exposureFilter imageFromCurrentlyProcessedOutput];
        } else {
            filtered = [self.filter imageFromCurrentlyProcessedOutput];
        }
        [filtered retain];
        [self.filter addTarget:self.preview];
    }];
    return [filtered autorelease];
}

- (void)applyFilter:(int)filterId withImages:(NSArray *)images deviceOrientation:(MRCamera_Orientation)orientation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        @autoreleasepool {
            [self.listener cameraControllerEvent:CameraControllerEvent_CaptureProcessBegan withArgs:nil];
            cpuFilter = [[FilterFactory createCPUFilter:filterId] retain];
            NSInteger setIndex = 0;//[self.filterManager setIndexOfFilterAtIndex:self.filterIndex atPhase:PhotoPhaseTake];
            [cpuFilter setProperty:@"effectIndex" value:[NSNumber numberWithInteger:setIndex]];
            cpuFilter.deviceOrientation = orientation;
            if (filterId == MIC_CPUEXPOSURE) {
                [cpuFilter setProperty:@"level" value:[NSNumber numberWithFloat:self.exposureLevel]];
            }
            cpuFilter.delegate = self;
            [cpuFilter setInputImages:images];
        }
    });
}


- (void)switchGPUFilter:(int)filterId
{
    dispatch_async([FilterFactory filterQueue], ^{
        @autoreleasepool {
            [GPUImageOpenGLESContext useImageProcessingContext];
            [self.exposureFilter removeAllTargets];
            self.filter = nil;
            self.filter = [FilterFactory createGPUFilter:filterId];
            NSInteger setIndex = 0;//[self.filterManager setIndexOfFilterAtIndex:self.filterIndex atPhase:PhotoPhaseTake];
            [self.filter setProperty:@"effectIndex" value:[NSNumber numberWithInteger:setIndex]];
            [self.exposureFilter addTarget:self.filter];
            [self.filter addTarget:self.preview];
        }
    });
}

- (BOOL)isMultiInputFilter
{
    return NO;//[self.filterManager isSingleInputFilterAtIndex:controller.filterIndex] != YES;
}

- (void)freezeDevice
{
    self.devicePaused = YES;
    [GPUImageOpenGLESContext sharedImageProcessingOpenGLESContext].ignoreNextFrame = YES;
    [FilterFactory finishGPUOperations];
}
- (void)unfreezeDevice
{
    self.devicePaused = NO;
    [GPUImageOpenGLESContext sharedImageProcessingOpenGLESContext].ignoreNextFrame = NO;
}

- (BOOL)hasDifferentSaveFilter:(NSInteger)filterIndex
{
//    if (filterIndex == MRFilterPrint) {
        return YES;
//    }
//    NSInteger preview = [self.filterManager previewOfFilterAtIndex:filterIndex];
//    NSInteger final = [self.filterManager finalOfFilterAtIndex:filterIndex andUseForFront:self.devicePosition == AVCaptureDevicePositionFront];
//    return preview != final;
}

- (UIImage *)zoomPhoto:(UIImage *)image withZoom:(CGFloat)zoom needScale:(BOOL)scale
{
    LOG_D(@"image size: %f, %f", image.size.width, image.size.height);
    CGRect rect = self.preview.bounds;
    CGFloat ratio = image.size.width / rect.size.width;
    CGSize size = CGSizeMake(rect.size.width * ratio / zoom, rect.size.height * ratio / zoom);
    
    rect.origin.x = (size.width - image.size.width) / 2;
    rect.origin.y = (size.height - image.size.height) / 2;
    rect.size = image.size;
    
    if (scale) {
        CGFloat newRatio = 640 / size.width;
        rect.origin.x *= newRatio; rect.origin.y *= newRatio;
        rect.size.width *= newRatio; rect.size.height *= newRatio;
        size = CGSizeMake(640, 852);
    }
    
    UIGraphicsBeginImageContext(size);
    [image drawInRect:rect];
    UIImage *result = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return result;
}

- (CGPoint)transformAVCaptureDevicePoint:(CGPoint)point
{
    CGPoint devPoint = point;
    CGFloat x = devPoint.x / self.preview.bounds.size.width;
    CGFloat y = devPoint.y / self.preview.bounds.size.height;
    devPoint.x = y;
    devPoint.y = 1 - x;
    
    if (device.position == AVCaptureDevicePositionFront) { //convert left/right.
        devPoint.y = 1- devPoint.y;
    }
    return devPoint;
}
- (CGPoint)unTransformAVCaptureDevicePoint:(CGPoint)point
{
    CGPoint devPoint = point;
    if (device.position == AVCaptureDevicePositionFront) {
        devPoint.y = 1 - devPoint.y;
    }
    CGFloat x = devPoint.x;
    CGFloat y = devPoint.y;
    devPoint.x = (1 - y) * self.preview.bounds.size.width;
    devPoint.y = x * self.preview.bounds.size.height;
    return devPoint;
}

- (void)detectFace:(CMSampleBufferRef)sampleBuffer
{
    if (faceDetector == nil) {
        NSDictionary *detectorOptions = [NSDictionary dictionaryWithObjectsAndKeys:CIDetectorAccuracyLow, CIDetectorAccuracy, nil];
        faceDetector = [[CIDetector detectorOfType:CIDetectorTypeFace context:nil options:detectorOptions] retain];
    }
	CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
	CFDictionaryRef attachments = CMCopyDictionaryOfAttachments(kCFAllocatorDefault, sampleBuffer, kCMAttachmentMode_ShouldPropagate);
	CIImage *ciImage = [[CIImage alloc] initWithCVPixelBuffer:pixelBuffer options:(NSDictionary *)attachments];
	if (attachments)
		CFRelease(attachments);
	NSDictionary *imageOptions = nil;
    MRCamera_Orientation curDeviceOrientation = MRCamera_Orientation_Up;// [MRDevice currentDevice].orientation;
    
	int exifOrientation;

	enum {
		PHOTOS_EXIF_0ROW_TOP_0COL_LEFT			= 1, //   1  =  0th row is at the top, and 0th column is on the left (THE DEFAULT).
		PHOTOS_EXIF_0ROW_TOP_0COL_RIGHT			= 2, //   2  =  0th row is at the top, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT      = 3, //   3  =  0th row is at the bottom, and 0th column is on the right.
		PHOTOS_EXIF_0ROW_BOTTOM_0COL_LEFT       = 4, //   4  =  0th row is at the bottom, and 0th column is on the left.
		PHOTOS_EXIF_0ROW_LEFT_0COL_TOP          = 5, //   5  =  0th row is on the left, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP         = 6, //   6  =  0th row is on the right, and 0th column is the top.
		PHOTOS_EXIF_0ROW_RIGHT_0COL_BOTTOM      = 7, //   7  =  0th row is on the right, and 0th column is the bottom.
		PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM       = 8  //   8  =  0th row is on the left, and 0th column is the bottom.
	};
	
	switch (curDeviceOrientation) {
		case UIDeviceOrientationPortraitUpsideDown:  // Device oriented vertically, home button on the top
			exifOrientation = PHOTOS_EXIF_0ROW_LEFT_0COL_BOTTOM;
			break;
		case UIDeviceOrientationLandscapeLeft:       // Device oriented horizontally, home button on the right
			if (self.devicePosition == AVCaptureDevicePositionFront)
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			break;
		case UIDeviceOrientationLandscapeRight:      // Device oriented horizontally, home button on the left
			if (self.devicePosition == AVCaptureDevicePositionFront)
				exifOrientation = PHOTOS_EXIF_0ROW_TOP_0COL_LEFT;
			else
				exifOrientation = PHOTOS_EXIF_0ROW_BOTTOM_0COL_RIGHT;
			break;
		case UIDeviceOrientationPortrait:            // Device oriented vertically, home button on the bottom
		default:
			exifOrientation = PHOTOS_EXIF_0ROW_RIGHT_0COL_TOP;
			break;
	}
    
	imageOptions = [NSDictionary dictionaryWithObject:[NSNumber numberWithInt:exifOrientation] forKey:CIDetectorImageOrientation];
	NSArray *features = [faceDetector featuresInImage:ciImage options:imageOptions];
	[ciImage release];
	
    // get the clean aperture
    // the clean aperture is a rectangle that defines the portion of the encoded pixel dimensions
    // that represents image data valid for display.
	CMFormatDescriptionRef fdesc = CMSampleBufferGetFormatDescription(sampleBuffer);
	CGRect clap = CMVideoFormatDescriptionGetCleanAperture(fdesc, false /*originIsTopLeft == false*/);
	
	dispatch_async(dispatch_get_main_queue(), ^(void) {
		[self drawFaceBoxesForFeatures:features forVideoBox:clap orientation:curDeviceOrientation];
	});
}
static CGFloat DegreesToRadians(CGFloat degrees) {return degrees * M_PI / 180;};
- (void)drawFaceBoxesForFeatures:(NSArray *)features forVideoBox:(CGRect)clap orientation:(UIDeviceOrientation)orientation
{
	NSArray *sublayers = [NSArray arrayWithArray:[self.preview.layer sublayers]];
	NSInteger sublayersCount = [sublayers count], currentSublayer = 0;
	NSInteger featuresCount = [features count], currentFeature = 0;
	
	[CATransaction begin];
	[CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
	
	// hide all the face layers
	for (CALayer *layer in sublayers ) {
		if ([[layer name] isEqualToString:@"FaceLayer"])
			[layer setHidden:YES];
	}
	
	if (featuresCount == 0 || self.faceMonitoringEnabled == NO) {
		[CATransaction commit];
		return; // early bail.
	}
    
	BOOL isMirrored = (self.devicePosition == AVCaptureDevicePositionFront);

    CGRect previewBox = self.preview.bounds;
	
	for ( CIFaceFeature *ff in features ) {
		// find the correct position for the square layer within the previewLayer
		// the feature box originates in the bottom left of the video frame.
		// (Bottom right if mirroring is turned on)
		CGRect faceRect = [ff bounds];
        
		// flip preview width and height
		CGFloat temp = faceRect.size.width;
		faceRect.size.width = faceRect.size.height;
		faceRect.size.height = temp;
		temp = faceRect.origin.x;
		faceRect.origin.x = faceRect.origin.y;
		faceRect.origin.y = temp;
		// scale coordinates so they fit in the preview box, which may be scaled
		CGFloat widthScaleBy = previewBox.size.width / clap.size.height;
		CGFloat heightScaleBy = previewBox.size.height / clap.size.width;
		faceRect.size.width *= widthScaleBy;
		faceRect.size.height *= heightScaleBy;
		faceRect.origin.x *= widthScaleBy;
		faceRect.origin.y *= heightScaleBy;
        
		if ( isMirrored )
			faceRect = CGRectOffset(faceRect, previewBox.origin.x + previewBox.size.width - faceRect.size.width - (faceRect.origin.x * 2), previewBox.origin.y);
		else
			faceRect = CGRectOffset(faceRect, previewBox.origin.x, previewBox.origin.y);
		
		CALayer *featureLayer = nil;

		// re-use an existing layer if possible
		while ( !featureLayer && (currentSublayer < sublayersCount) ) {
			CALayer *currentLayer = [sublayers objectAtIndex:currentSublayer++];
			if ( [[currentLayer name] isEqualToString:@"FaceLayer"] ) {
				featureLayer = currentLayer;
				[currentLayer setHidden:NO];
			}
		}

		// create a new one if necessary
		if ( !featureLayer ) {
			featureLayer = [CALayer new];
			//[featureLayer setContents:(id)[square CGImage]];
			[featureLayer setName:@"FaceLayer"];
            featureLayer.backgroundColor = [UIColor redColor].CGColor;
            featureLayer.opacity = 0.5;
			[self.preview.layer addSublayer:featureLayer];
			[featureLayer release];
		}
		[featureLayer setFrame:faceRect];
		
		switch (orientation) {
			case UIDeviceOrientationPortrait:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(0.))];
				break;
			case UIDeviceOrientationPortraitUpsideDown:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(180.))];
				break;
			case UIDeviceOrientationLandscapeLeft:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(90.))];
				break;
			case UIDeviceOrientationLandscapeRight:
				[featureLayer setAffineTransform:CGAffineTransformMakeRotation(DegreesToRadians(-90.))];
				break;
			case UIDeviceOrientationFaceUp:
			case UIDeviceOrientationFaceDown:
			default:
				break; // leave the layer in its last known orientation
		}
		currentFeature++;
	}
	
	[CATransaction commit];
}

#pragma mark * CPUImageFilterDelegate *
- (void)processFinished:(UIImage *)processed
{
    LOG_METHOD;
    BOOL needVS = NO;//[self.filterManager isCompareFilterAtIndex:self.filterIndex];
    if (/*controller.filterIndex == MRFilterNone &&*/ self.exposureLevel != 0) {
        [self.listener cameraControllerEvent:CameraControllerEvent_CaptureEnded withArgs:@{@"preview": [self currentImageFromFilter:self.filter], @"save": processed}];
    } else {
        [self.listener cameraControllerEvent:CameraControllerEvent_CaptureProcessEnded withArgs:@{@"normal": self.originImage, @"effect": processed, @"compare":@(needVS)}];
    }
    self.originImage = nil;

    cpuFilter.delegate = nil;
    [cpuFilter release];
    cpuFilter = nil;
}

#pragma mark * CamereVideoDeviceDelegate *

- (void)cameraDeviceEvent:(CameraDeviceEvent)event withAguments:(NSDictionary *)args
{
    switch (event) {
        case CameraDeviceEvent_Started:
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listener cameraControllerEvent:CameraControllerEvent_Started withArgs:nil];
            });
            break;
        case CameraDeviceEvent_Stopped:
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listener cameraControllerEvent:CameraControllerEvent_Stopped withArgs:nil];
            });
            break;
        case CameraDeviceEvent_Restarted:
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listener cameraControllerEvent:CameraControllerEvent_Restarted withArgs:nil];
            });
            break;
        case CameraDeviceEvent_FrameStarted:
            break;
        case CameraDeviceEvent_FrameReceived:
        {
            CMSampleBufferRef buffer = (CMSampleBufferRef)[[args objectForKey:@"buffer"] integerValue];
            AVCaptureDevicePosition position = [[args objectForKey:@"position"] integerValue];
            [self processFrameBuffer:buffer withPosition:position];
        }
            break;
        case CameraDeviceEvent_PositionChanged:
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.listener cameraControllerEvent:CameraControllerEvent_PositionChanged withArgs:@{@"position": @(self.devicePosition), @"rotated": @YES}];
            });
            break;
        case CameraDeviceEvent_FlashModeSetted:
            break;
        case CameraDeviceEvent_FocusBegan:
            dispatch_async(dispatch_get_main_queue(), ^{
                CGPoint ptDevice;
                ptDevice.x = [[args objectForKey:@"x"] floatValue];
                ptDevice.y = [[args objectForKey:@"y"] floatValue];
                CGPoint ptView = [self unTransformAVCaptureDevicePoint:ptDevice];
                [self.listener cameraControllerEvent:CameraControllerEvent_FocusBegan withArgs:@{@"x": @(ptView.x), @"y": @(ptView.y)}];
            });
            break;
        case CameraDeviceEvent_FocusEnded:
            break;
        case CameraDeviceEvent_ExposureBegan:
            break;
        case CameraDeviceEvent_ExposureEnded:
            break;
        default:
            break;
    }
}

@end
