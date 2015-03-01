//
//  CameraViewController.m
//
//
//  Created by sky on 14-11-4.
//  Copyright (c) 2014年 DW. All rights reserved.
//

#import "CameraViewController.h"
//#import "FilterListView.h"
#import "CameraPhotoDevice.h"
//#import "UIImage+Resize.h"
#import <FilterEngine/FilterEnum.h>
#import <FilterEngine/FilterFactory.h>
#import <FilterEngine/UIImageOrientationFilter.h>
#import <FilterEngine/GPUImageFilter.h>
#import <FilterEngine/GPUImageView.h>

@interface CameraViewController () <CameraVideoDeviceDelegate>
{
    IBOutlet UIView *contentView; // 上面放置了video
    IBOutlet UIButton *btnFlash;
    IBOutlet UIButton *btnCamera;
    IBOutlet UIButton *btnNight;
    IBOutlet UIButton *btnTimer;
    IBOutlet UISlider *sliderParam;
    //下方功能bar，cancel，filter等都在上面
    IBOutlet UIView * bottomBar;
    IBOutlet UIButton *btnCancel;
    IBOutlet UIButton *btnPhoto;
    IBOutlet UIButton *btnFilter;
    
//    IBOutlet FilterListView *listView;
    
    CameraPhotoDevice *device;
    
    NSInteger selectedFilterId;
    
    BOOL btnPhotoLongPressed;
    
//    TTModeSelectLayout * _layoutModeSelect;
//    CameraBottomBar * cameraBottomBar;
}

@property (nonatomic, strong) UIImageOrientationFilter *rotationFilter;
@property (nonatomic, strong) GPUImageFilter *exposureFilter;
@property (nonatomic, strong) GPUImageFilter *filter;
@property (nonatomic, strong) GPUImageView *preview;

@property (nonatomic, retain) NSMutableArray *ciFaceLayers;
//@property (nonatomic, retain) WMCDynamicMoodLayer *featureLayer;

@property (nonatomic, strong) NSArray * filterItemList;
@property (nonatomic, strong) NSMutableDictionary * complexFilterSelected; // 复合滤镜选中的index

@property (nonatomic, assign) NSInteger videoRecordingStatus;
@end

@implementation CameraViewController

- (id)init
{
//    NSString *xibName = [UIScreen mainScreen].bounds.size.height > 480 ? @"CameraViewController-568h" : @"CameraViewController";
    NSString *xibName = @"CameraViewController";
    self = [super initWithNibName:xibName bundle:nil];
    if (self) {
        device = [[CameraPhotoDevice alloc] initWithPosition:AVCaptureDevicePositionBack];
        device.delegate = self;
        
        self.filterItemList = [self filterList];
        
//        _layoutModeSelect = [[TTModeSelectLayout alloc] init];
//        _layoutModeSelect.currentMode = 2;
    }
    return self;
}

- (void)dealloc
{
    device.delegate = nil;
    [device stopDevice];
    
//    cameraBottomBar.delegate = nil;
//    cameraBottomBar = nil;
    self.filterItemList = nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [listView layoutWithList:[self filterList]];
//    listView.delegate = self;
    
    UILongPressGestureRecognizer *gesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedBtnPhoto:)];
    [btnPhoto addGestureRecognizer:gesture];
    
    UILongPressGestureRecognizer *longGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressedBtnPhoto:)];
    UITapGestureRecognizer * tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cameraTapGesturePhoto:)];
    [tapGesture requireGestureRecognizerToFail:longGesture];
    [contentView addGestureRecognizer:longGesture];
    [contentView addGestureRecognizer:tapGesture];
    
    // bottombar
//    cameraBottomBar = [[CameraBottomBar alloc] initWithFrame:bottomBar.bounds];
//    cameraBottomBar.delegate = self;
//    cameraBottomBar.autoresizingMask = 0xff;
//    cameraBottomBar.filterItemList = _filterItemList;
//    cameraBottomBar.complexFilterSelected = self.complexFilterSelected;
//    [cameraBottomBar commonInitListWithLayout:_layoutModeSelect];
//    [bottomBar addSubview:cameraBottomBar];
    
    // 还原部分数据
    [self setupFlashButtonWithFlashMode:device.flashMode];
    [self setupNightModeWithParams:device.nightMode];
    
//    [[TTSelectedAssetManager sharedManager] clearMemory];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    contentView = nil;
    self.preview = nil;
    btnFlash = nil;
    btnCamera = nil;
    sliderParam = nil;
    bottomBar = nil;
    btnCancel = nil;
    btnPhoto = nil;
    btnFilter = nil;
    
//    cameraBottomBar.delegate = nil;
//    cameraBottomBar = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [device startDevice];

}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CGRect superRect = self.view.bounds;
    
    float videoX = 0, videoY = 0;
    float videoW = superRect.size.width, videoH = floorf(superRect.size.width * 4 / 3);
    CGRect videoFrame = CGRectMake(videoX, videoY, videoW, videoH);
    contentView.frame = videoFrame;
    
    float bottomBarY = videoY + videoH;
    float bottomBarH = superRect.size.height - bottomBarY;
    bottomBar.frame = CGRectMake(0, bottomBarY, superRect.size.width, bottomBarH);
}


#pragma mark - Internal

- (NSArray *)filterList
{
    return @[
             @{@"name":@"无", @"id":@(MIC_LENS),@"icon":@"00原片.jpg"},
             @{@"name":@"磨皮", @"id":@(MIC_Portait0), @"icon":@"01美白.jpg"},
             ];

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
    
    if (self.preview == nil) {
        self.preview = [[GPUImageView alloc] initWithFrame:contentView.bounds];
        _preview.autoresizingMask = 0xff;
        [contentView addSubview:self.preview];
    }
    [self.filter addTarget:self.preview];
}

- (void)processFrameBuffer:(CMSampleBufferRef)buffer withPosition:(AVCaptureDevicePosition)position
{
    [FilterFactory runBlockInFilterQueueSync: ^{
        [GPUImageOpenGLESContext useImageProcessingContext];
        if (self.exposureFilter == nil) {
            [self setupFilterEnv];
        }
        
//        if (self.notifyNextFrame) {
//            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
//            [self.listener cameraControllerEvent:CameraControllerEvent_VideoReceived withArgs:nil];
//            controller.filterIndex = controller.filterIndex;
//            self.notifyNextFrame = NO;
//        }
        
        CVImageBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(buffer);
        
        CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(buffer);
        
        [self.rotationFilter setOrientationMode:UIImageOrientationRight];
        [self.rotationFilter setFlipMode:device.position != AVCaptureDevicePositionFront ? UIImageFlipNone : UIImageFlipHorizontal];
#if USE_YUV
        [self.rotationFilter setInputPixelBuffer:pixelBuffer withFormat:UIImageFormat420V];
#else
        [self.rotationFilter setInputPixelBuffer:pixelBuffer withFormat:UIImageFormatRGBA];
#endif
        [self.filter setWidth:[self.rotationFilter getOutputSize].width andHeight:[self.rotationFilter getOutputSize].height];
        [self.rotationFilter newFrameReadyAtTime:currentTime];
    }];
}


- (void) drawFaceBoxesForFeatures:(NSArray *)features
                        imageSize:(CGSize)imageSize
                      orientation:(UIInterfaceOrientation)orientation
{}


#pragma mark - Events
- (IBAction)handleCancelEvent:(UIButton *)sender
{
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

- (IBAction)handleFlashEvent:(UIButton *)sender
{
    sender.tag = (sender.tag + 1) % 3;
    CameraFlashMode flashmode = (CameraFlashMode)sender.tag;
    
    device.flashMode = flashmode;
    [self setupFlashButtonWithFlashMode:flashmode];
}
- (IBAction)handleCameraEvent:(UIButton *)sender
{
    if (device.position == AVCaptureDevicePositionFront) {
        device.position = AVCaptureDevicePositionBack;
    } else {
        device.position = AVCaptureDevicePositionFront;
    }
}
- (IBAction)onButtonNightModeClicked:(UIButton *)sender
{
    device.nightMode = (device.nightMode+1) % CameraPhotoDeviceNightModeCount;
    [self setupNightModeWithParams:device.nightMode];
}
- (IBAction)onButtonTimerModeClicked:(UIButton *)sender
{
    
}
- (IBAction)handleParamSliderEvent:(UISlider *)sender
{
    [FilterFactory runBlockInFilterQueueAsync:^{
        [self.filter setProperty:@"smooth" value:@(sender.value)];
    }];
}
- (IBAction)handleFilterEvent:(UIButton *)sender
{
    sender.tag = !sender.tag;
//    listView.hidden = sender.tag;
    if (self.videoRecordingStatus == 0) {
        self.videoRecordingStatus = 1;
        [device startRecording];
        [btnFilter setTitle:@"录制中" forState:UIControlStateNormal];
    } else if (self.videoRecordingStatus == 1) {
        self.videoRecordingStatus = 0;
        [device stopRecording];
        [btnFilter setTitle:@"录制" forState:UIControlStateNormal];
    }
}

- (IBAction)handlePhotoEvent:(UIButton *)sender
{
    self.view.userInteractionEnabled = NO;
    [device capturePhotoWhenComplete:^(CMSampleBufferRef sampleBuffer, NSError *error) {
        @autoreleasepool {
//            UIImage *image = [self.filter imageFromCurrentlyProcessedOutput];
//            
//            NSDictionary * exifAttachments = (__bridge NSDictionary *)CMGetAttachment(sampleBuffer, kCGImagePropertyExifDictionary, NULL);
//            NSMutableDictionary * metaData = [WMCSaveManager metadataWithImage:image exif:exifAttachments originMetadata:nil takePhoto:nil modifyPhoto:nil location:nil];
//            CFAbsoluteTime start = CFAbsoluteTimeGetCurrent();
//            
//            [WMCSaveManager saveImage:image info:metaData completionWithAsset:^(ALAsset *asset, NSError *error2) {
//                if (asset && !error2) {
////                    QZAsset *ass = [[QZAsset alloc] initWithALAsset:asset withAlbumID:[QZImagePickerManager cameraRollGroupID]];
////                    [ass autoFillURL];
////                    [[TTSelectedAssetManager sharedManager] addQZAsset:ass];
//                }
//            }];
//            [WMCSaveManager saveImage:image metadata:metaData saveToGroup:YES completion:^(NSURL *assetURL, NSError *aError){
//                NSLog(@"saveImage success %@ , time cost %lf", assetURL, CFAbsoluteTimeGetCurrent()-start);
//                
//                
//            }];
            // UIImageWriteToSavedPhotosAlbum(image, nil, NULL, NULL);
            //        self.view.userInteractionEnabled = YES;
            
            UIView *view = [[UIView alloc] initWithFrame:self.view.bounds];
            view.backgroundColor = [UIColor whiteColor];
            [self.view addSubview:view];
            [UIView animateWithDuration:0.4 animations:^{
                view.alpha = 0.0f;
            } completion:^(BOOL finished) {
                [view removeFromSuperview];
                
//                [cameraBottomBar setAlbumImage:image count:1];
            }];
            // 长按连拍功能
            if (btnPhotoLongPressed)
            {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [self handlePhotoEvent:nil];
                });
            }
            else
            {
                self.view.userInteractionEnabled = YES;
            }
        }
    }];
}

#pragma mark - 内部方法

- (void)setupFlashButtonWithFlashMode:(CameraFlashMode)flashmode
{
    NSArray *modeNDescs = @[@"flash_auto.png", @"flash_off.png", @"flash_on.png",];
//    if ([UIScreen mainScreen].isiPhone169) {
//        modeNDescs = @[@"4flashoff.png", @"4flashon.png", @"4flashauto.png", @"4flashon.png"];
//    } else {
//        modeNDescs = @[@"3.5flashoff.png", @"3.5flashon.png", @"3.5flashauto.png", @"3.5flashon.png"];
//    }
    UIImage * image = [UIImage imageNamed:modeNDescs[flashmode]];
    [btnFlash setImage:image forState:UIControlStateNormal];
    [btnFlash setImage:image forState:UIControlStateHighlighted];
    [btnFlash setImage:image forState:UIControlStateDisabled];
}

- (void)setupNightModeWithParams:(CameraPhotoDeviceNightMode)mode
{
    NSArray *modeNDescs = @[@"nightmode_off.png", @"nightmode_on.png",];
    UIImage * image = [UIImage imageNamed:modeNDescs[mode]];
    [btnNight setImage:image forState:UIControlStateNormal];
    [btnNight setImage:image forState:UIControlStateHighlighted];
    [btnNight setImage:image forState:UIControlStateDisabled];
}

#pragma mark - bottombar的回调

- (void)longPressedBtnPhoto:(UILongPressGestureRecognizer *)longPress
{
    if (longPress.state == UIGestureRecognizerStateBegan)
    {
        btnPhotoLongPressed = YES;
        btnPhoto.highlighted = YES;
        [self handlePhotoEvent:nil];
    }
    else if (longPress.state == UIGestureRecognizerStateEnded || longPress.state == UIGestureRecognizerStateCancelled)
    {
        btnPhotoLongPressed = NO;
        btnPhoto.highlighted = NO;
    }
}

- (void)cameraTapGesturePhoto:(UITapGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self handlePhotoEvent:nil];
    }
}

//- (void)cameraBottomBar:(CameraBottomBar *)theBar buttonClickedWithType:(CameraBottomBarButtonType)type
//{
//    if (type == CameraBottomBarButtonTypeCancel)
//    {
//        [self handleCancelEvent:nil];
//    } else if (type == CameraBottomBarButtonTypeAlbum) {
////        TTCameraBoxViewController * box = [[TTCameraBoxViewController alloc] initWithPhotos:[[TTSelectedAssetManager sharedManager] qzAssets]];
////        [self.navigationController pushViewController:box animated:NO];
//        [device stopDevice];
////        [[WMCStatistic shareInstance] pushOperation:kOpLevelTwoCameraUseOpenBox];
//    }
//}
//
//- (void)cameraBottomBar:(CameraBottomBar *)theBar didSelectAtIndex:(int)index withId:(NSInteger)filterId andSubId:(NSInteger)effectId
//{
////    [self filterListView:nil didSelectedAtIndex:index withId:filterId andSubId:effectId];
//}

//#pragma mark - FilterListViewDelegate
//- (void)filterListView:(FilterListView *)list didSelectedAtIndex:(NSInteger)index withId:(NSInteger)filterId andSubId:(NSInteger)effectId
//{
//    [FilterFactory runBlockInFilterQueueAsync:^{
//        [self.rotationFilter removeAllTargets];
//        [self.filter removeAllTargets];
//        
//        self.filter = [FilterFactory createGPUFilter:(int)filterId];
//        [self.filter setProperty:@"smooth" value:@(sliderParam.value)];
//        [self.rotationFilter addTarget:self.filter];
//        [self.filter addTarget:self.preview];
//    }];
//}
#pragma mark - CameraVideoDeviceDelegate
- (void)cameraDeviceEvent:(CameraDeviceEvent)event withAguments:(NSDictionary *)args
{
    switch (event) {
        case CameraDeviceEvent_Started:
            break;
        case CameraDeviceEvent_Stopped:
            break;
        case CameraDeviceEvent_Restarted:
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
            break;
        case CameraDeviceEvent_FlashModeSetted:
            break;
        case CameraDeviceEvent_FocusBegan:
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
