//
//  FirstViewController.m
//  catRing
//
//  Created by sky on 15/2/17.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "FirstViewController.h"

#import "PreHeader.h"

// UI
#import "LabelSliderGroup.h"
#import "SVProgressHUD.h"
// UI


// algorithm
#import <opencv2/highgui/ios.h>
#import "mymain.hpp"
#import "handGesture.hpp"
#import "myImage.hpp"
// algorithm

// utility
#import "DWIplImageHelper.h"
#import "DWUtility.h"
// utility

// video decoding
#import "DWVideoDecoding.h"
// video decoding

#import "DWRotationManager.h"

#import "ImageProcess.h"
#import "UIImage+OpenCV.h"

#import "DWRingPositionInfo.h"
#import "DWRingPosModel.h"

#import "SelectPointViewController.h"
#import "CEMovieMaker.h"
#import <MediaPlayer/MPMoviePlayerViewController.h>
#import <MediaPlayer/MPMoviePlayerController.h>

#import "PreHeader.h"

#import <FilterEngine/ImageSelectorHandle.h>
#import <FilterEngine/UIImageUtils.h>
#import <FilterEngine/UIImage+Image.h>
#import <FilterEngine/type_common.h>

#define TimeStamp(index) dprintf("\ntimestamp[%d] = <%f>",index,CACurrentMediaTime());


@interface RotationAngle : NSObject {
}
@property (nonatomic, assign) double x;
@property (nonatomic, assign) double y;
@property (nonatomic, assign) double z;

@end
@implementation RotationAngle
{
 
}
-(id)init
{
    if(self=[super init])
    {
        self.x = 0;
        self.y = 0;
        self.z = 0;
    }
    return self;
}
@end

@interface FirstViewController () {
    
//    HandGesture * ppreviousHand;
//    HandGesture * previousHand;
    HandGesture * currentHand;
    BOOL firstTime;
    ImageSelectorHandle *lazyHandle;
}

@property (nonatomic, retain) UIImageView *imageView;

@property (nonatomic, retain) LabelSlider *labelSlider;
@property (nonatomic, retain) LabelSlider *diffSlider;
@property (nonatomic, retain) LabelSlider *picturesSlider;

@property (nonatomic, strong) DWVideoDecoding *videoEncoder;

@property (nonatomic, assign) NSInteger totalVideoFrame;

@property (nonatomic, retain) NSMutableArray * angleArray;

@property (nonatomic, retain) NSMutableArray * ringCenterArray;

@property (nonatomic, assign) NSInteger imageIndex;

@property (nonatomic, strong) CEMovieMaker *movieMaker;
@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) DWRotationManager* rotationManager;

@property (nonatomic, strong) NSMutableDictionary *filenamePositionInfoDic;

@property (nonatomic, strong) NSMutableDictionary *indexXYZDic;
@property (nonatomic, strong) NSMutableDictionary *indexRingPosDic;
@property (nonatomic, retain) NSMutableArray * frames;

@property (nonatomic, assign) BOOL canClick;

@property (nonatomic, assign) NSInteger diff;
@end

@implementation FirstViewController

const int kStep = 2;

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        lazyHandle = [ImageSelectorHandle handleWithType:PaintType_LazySanpping image:nil];
        lazyHandle.mode = PaintMode_SmartBrush;
    }
    return self;
}

- (void)handleSetImage:(UIImage *)image {
    [lazyHandle setImage:image];
}

- (void)setHandlePath:(NSArray *)paths {
    NSInteger i, count = paths.count;
    
    if (count > 1) {
        NSValue *p1 = (NSValue *)paths.firstObject;
        
        CGPoint pstart = [p1 CGPointValue];
        
        [lazyHandle touchBeganAt:pstart];
        
        for (i = 1; i < count; ++i) {
            NSValue *pi = (NSValue *)paths[i];
            CGPoint pmiddle = [pi CGPointValue];
            
            CGFloat paintSize = 37.5/ 1 / 2;
            paintSize *= [UIScreen mainScreen].scale;
            paintSize = paintSize * 2 / 3;
            [lazyHandle touchMovedTo:pmiddle radius:0 extend:paintSize];
        }
        
        [lazyHandle touchEnded];
    }
}

- (NSMutableDictionary *)indexXYZDic {
    if (!_indexXYZDic) {
        _indexXYZDic = [NSMutableDictionary dictionary];
    }
    return _indexXYZDic;
}

- (NSMutableDictionary *)indexRingPosDic {
    if (!_indexRingPosDic) {
        _indexRingPosDic = nil;
        NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *fileName = [betaCompressionDirectory stringByAppendingPathComponent: @"indexRingPosDic"];
        id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            _indexRingPosDic = [(NSDictionary *)obj mutableCopy];
        } else {
            _indexRingPosDic = [NSMutableDictionary dictionary];
        }
    }
    return _indexRingPosDic;
}

- (NSMutableDictionary *)filenamePositionInfoDic {
    if (!_filenamePositionInfoDic) {
        _filenamePositionInfoDic = nil;
        NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        NSString *fileName = [betaCompressionDirectory stringByAppendingPathComponent: @"filenamePositionInfoDic"];
        id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
        if ([obj isKindOfClass:[NSDictionary class]]) {
            _filenamePositionInfoDic = [(NSDictionary *)obj mutableCopy];
        } else {
            NSString *fileName = [[NSBundle mainBundle] pathForResource:@"filenamePositionInfoDic" ofType:@""];
            id obj = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
            if ([obj isKindOfClass:[NSDictionary class]]) {
                _filenamePositionInfoDic = [(NSDictionary *)obj mutableCopy];
            } else {
                _filenamePositionInfoDic = [NSMutableDictionary dictionary];
            }
        }
    }
    return _filenamePositionInfoDic;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    firstTime = YES;
    self.canClick = YES;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    UIImage *image = [UIImage imageNamed:@"IMG_0835.JPG"];
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    LabelSlider *labelSlider = [[LabelSlider alloc] initWithFrame:CGRectMake(30, 90, self.view.bounds.size.width-60, 20)];
    [labelSlider.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventTouchUpInside];
//    [labelSlider.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventTouchUpOutside];
    labelSlider.label.text = nil;
    labelSlider.slider.minimumValue = 0.0f;
    labelSlider.slider.maximumValue = 1.0f;
    [self.view addSubview:labelSlider];
    self.labelSlider = labelSlider;
    
    {
        self.diff = 30 / kStep;
//        self.diff = 20;
        LabelSlider *labelSlider = [[LabelSlider alloc] initWithFrame:CGRectMake(30, 120, self.view.bounds.size.width-60, 20)];
        [labelSlider.slider addTarget:self action:@selector(onDiffValueChanged:) forControlEvents:UIControlEventTouchUpInside];
//        [labelSlider.slider addTarget:self action:@selector(onDiffValueChanged:) forControlEvents:UIControlEventTouchUpOutside];
        labelSlider.label.text = [NSString stringWithFormat:@"%zd", self.diff];
        labelSlider.slider.minimumValue = 6.0f;
        labelSlider.slider.maximumValue = 20.0f;
        labelSlider.slider.value = self.diff;
        [self.view addSubview:labelSlider];
        self.diffSlider = labelSlider;
    }
    
    {
        LabelSlider *labelSlider = [[LabelSlider alloc] initWithFrame:CGRectMake(30, self.view.bounds.size.height - 30, self.view.bounds.size.width-60, 20)];
        [labelSlider.slider addTarget:self action:@selector(onPicturesValueChanged:) forControlEvents:UIControlEventValueChanged];
        labelSlider.slider.minimumValue = .0f;
        labelSlider.slider.maximumValue = 1.0f;
        labelSlider.slider.value = 0;
        [self.view addSubview:labelSlider];
        self.picturesSlider = labelSlider;
    }
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeCustom];
    previousButton.frame = CGRectMake(20, self.view.frame.size.height - 80, 60, 40);
    [previousButton addTarget:self action:@selector(onPreviousButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [previousButton setTitle:@"上一张" forState:UIControlStateNormal];
    [previousButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:previousButton];
    
#if kDevelop
    UIButton *middleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    middleButton.frame = CGRectMake(130, self.view.frame.size.height - 80, 60, 40);
    [middleButton addTarget:self action:@selector(onMiddleButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [middleButton setTitle:@"视频" forState:UIControlStateNormal];
    [middleButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:middleButton];
#endif
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
    nextButton.frame = CGRectMake(self.view.frame.size.width - 80, self.view.frame.size.height - 80, 60, 40);
    [nextButton addTarget:self action:@selector(onNextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [nextButton setTitle:@"下一张" forState:UIControlStateNormal];
    [nextButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [self.view addSubview:nextButton];
    
//    UIButton *pickColorButton = [UIButton buttonWithType:UIButtonTypeCustom];
//    pickColorButton.frame = CGRectMake(self.view.frame.size.width / 2 - 30, self.view.frame.size.height - 80 - 20, 60, 40);
//    [pickColorButton addTarget:self action:@selector(onPickColorButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
//    [pickColorButton setTitle:@"选肤色" forState:UIControlStateNormal];
//    [pickColorButton setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
//    [self.view addSubview:pickColorButton];
    
    [DWUtility createFolder:[self outputDir]];
    
    [self.view addSubview:self.indicator];
    self.indicator.center = self.view.center;
    [self.indicator stopAnimating];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIActivityIndicatorView *)indicator {
    if (!_indicator) {
        _indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _indicator.hidesWhenStopped = YES;
    }
    return _indicator;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
#if 1
    if (firstTime) {
        firstTime = NO;
        [self.indicator startAnimating];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            CFTimeInterval startTime = CACurrentMediaTime();


            [self getAllImageFromVideo];
            CFTimeInterval endTime = CACurrentMediaTime();
            DLog(@"[abc]difftime1 = %g", (endTime - startTime));
            [self processAllImages];
            endTime = CACurrentMediaTime();
            DLog(@"[abc]difftime2 = %g", (endTime - startTime));
            [self.indicator stopAnimating];
            [self showImageAtIndex:1 needAdjustDiff:YES];
        });
    }
#endif
    
//    [self showImageAtIndex:1];
}


NSInteger radiusToDegree(CGFloat angle) {
    return int(angle * 180 / M_PI);
}

-(double) reduceDefect:(double)previous middle:(double)middle next:(double)next
{
    if (abs(previous - next) < abs(previous)/4) {
        double midnum = (previous + next ) /2;
        
        if(abs(middle - midnum) > abs(midnum)/5 )
            return midnum;
        else
            return middle;
    }
    return middle;
}
-(void) reduceDefectForRingCenter
{
    NSMutableArray * array = self.ringCenterArray;
    for (int i = 1 ; i<array.count -1 ; i++)
    {
        
        Point2i previousCenter;
        [[array objectAtIndex:i-1] getValue:&previousCenter];
        
        Point2i currentCenter;
        [[array objectAtIndex:i] getValue:&currentCenter];
        
        Point2i nextCenter;
        [[array objectAtIndex:i+1] getValue:&nextCenter];
 
        
        currentCenter.x = [self reduceDefect:previousCenter.x middle:currentCenter.x next:nextCenter.x];
        currentCenter.y = [self reduceDefect:previousCenter.y middle:currentCenter.y next:nextCenter.y];
        
        [array setObject:[NSValue valueWithBytes:&currentCenter objCType:@encode(Point2i)] atIndexedSubscript:i];
//        [result addObject:currentAngles];
    }
}

-(void) reduceDefectForRotationAngle:(NSArray *)array
{
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (int i = 1 ; i<array.count -1 ; i++)
    {
        
        RotationAngle * previousAngle = [array objectAtIndex:i-1];
        RotationAngle * currentAngles = [array objectAtIndex:i];
        RotationAngle * nextAngles = [array objectAtIndex:i+1];
        
        currentAngles.x = [self reduceDefect:previousAngle.x middle:currentAngles.x next:nextAngles.x];
        currentAngles.y = [self reduceDefect:previousAngle.y middle:currentAngles.y next:nextAngles.y];
        currentAngles.z = [self reduceDefect:previousAngle.z middle:currentAngles.z next:nextAngles.z];
        [result addObject:currentAngles];
    }
}

-(void)smoothRingCenter
{
    [self reduceDefectForRingCenter];
    NSMutableArray * array = self.ringCenterArray;
    
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:array.count];
    [result addObject:[array objectAtIndex:0]];

    for (int i = 1 ; i<array.count -2 ; i++)
    {
        Point2i previousCenter;
        [[array objectAtIndex:i-1] getValue:&previousCenter];
        
        Point2i currentCenter;
        [[array objectAtIndex:i] getValue:&currentCenter];
        
        Point2i nextCenter;
        [[array objectAtIndex:i+1] getValue:&nextCenter];
        
        if(nextCenter.x == 0 || nextCenter.y ==0)
        {
            [result addObject:[NSValue valueWithBytes:&currentCenter objCType:@encode(Point2i)]];
            continue;
        }
        
        Point2i newCenter;
        
        newCenter.x = (previousCenter.x + currentCenter.x + nextCenter.x) /3;
        newCenter.y = (previousCenter.y + currentCenter.y + nextCenter.y) /3;
        [result addObject:[NSValue valueWithBytes:&newCenter objCType:@encode(Point2i)]];
    }
    [result addObject:[array objectAtIndex:array.count - 2]];
    [result addObject:[array objectAtIndex:array.count - 1]];
    self.ringCenterArray = result;
}

-(NSMutableArray *)smoothRotationAngle:(NSArray *)array
{
    [self reduceDefectForRotationAngle:array];
    
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (int i = 1 ; i < array.count - 1; i++)
    {
        RotationAngle * previousAngle = [array objectAtIndex:i-1];
        RotationAngle * currentAngles = [array objectAtIndex:i];
        RotationAngle * nextAngles = [array objectAtIndex:i+1];
        
        RotationAngle * newAngles = [RotationAngle alloc];
 
        newAngles.x = (previousAngle.x + currentAngles.x + nextAngles.x) /3;
        newAngles.y = (previousAngle.y + currentAngles.y + nextAngles.y) /3;
        newAngles.z = (previousAngle.z + currentAngles.z + nextAngles.z) /3;
        
        [result addObject:newAngles];
    }
    
    for(int i = 0 ; i<array.count  ; i++)
    {
        RotationAngle * currentAngles = [array objectAtIndex:i];
        DLog(@"oringinal angles: %f, %f ,%f", currentAngles.x,currentAngles.y,currentAngles.z);
    }
    
    for(int i = 0 ; i<result.count  ; i++)
    {
        RotationAngle * resultAngles = [result objectAtIndex:i];
        DLog(@"smoothed angles: %f, %f ,%f", resultAngles.x,resultAngles.y,resultAngles.z);
    }
    return result;
}

- (UIImage *)getVideoImageAtIndex:(NSInteger)i {
    UIImage *image = [UIImage imageWithContentsOfFile:[NSString stringWithFormat:@"%@/MYIMG_ORI%zd.JPG", [self outputDir], i]];
#if kUseLowResolution
//    return Point2i(320 - y * 320, 180 - x * 180);
    image = [ImageProcess correctImage:image toFitIn:CGSizeMake(kLowResolutionLongSize, kLowResolutionShortSize)];
//    image = [ImageProcess correctImage:image toFitIn:CGSizeMake(568, 320)];
    image = [self rotateImage:image withRadian:(M_PI_4 * 2 + M_PI_4 * 2) shrinkRatio:1.f];
#endif

    return image;
}

-(void)processAllImages
{
//    __block NSString *betaCompressionDirectory = nil;
//    betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    //    betaCompressionDirectory = ];
//    
//    //    NSString *fileName = [NSString stringWithFormat:@"MYIMG_SMALL%zd.JPG", j];
//    NSLog(@"current filename=%@", betaCompressionDirectory);
    //    image = [UIImage imageNamed:fileName];
    
    
//    self.filenamePositionInfoDic = [[NSMutableDictionary alloc ] initWithContentsOfFile:  [betaCompressionDirectory stringByAppendingPathComponent: @"filenamePositionInfoDic"]];

    
//    [self.rotationManager pushAngleX:90 angleY:0 angleZ:0];
//    [self.rotationManager pushAngleX:90 angleY:0 angleZ:0];
    
//    if (self.indexRingPosDic.allKeys.count > 10)
//        return;
    
    int j;
    for( j = 0 ; j < self.labelSlider.slider.maximumValue ; j++) //&& j < 15; j++)
    {
        @autoreleasepool {
            
            self.title = [NSString stringWithFormat:@"%@ %zd/%zd", [self.videoPath lastPathComponent], j, self.totalVideoFrame];
            //    [self wmcSetNavigationBarTitleStyle];
            
            
//            self.title = [NSString stringWithFormat:@"%zd", j];
            //    [self wmcSetNavigationBarTitleStyle];
            
            //        UIImage *image = nil;
            //        //    NSString *fileName = [NSString stringWithFormat:@"MYIMG_ORI%zd.JPG", j];
            //        __block NSString *betaCompressionDirectory = nil;
            //        betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            //        //    betaCompressionDirectory = ];
            //
            //        //    NSString *fileName = [NSString stringWithFormat:@"MYIMG_SMALL%zd.JPG", j];
            ////        NSLog(@"current filename=%@", betaCompressionDirectory);
            //        //    image = [UIImage imageNamed:fileName];
            
            self.imageIndex = j;
            
            UIImage *image = [self getVideoImageAtIndex:j];
            //    self.imageView.image = [self processImage:image];
            
            if(!image)
                return;
            
            [self processImage:image needAdjustDiff:NO];
            
            if(!_ringCenterArray)
                self.ringCenterArray = [[NSMutableArray alloc] initWithCapacity:10];
            [self.ringCenterArray addObject:[NSValue valueWithBytes:&currentHand->ringCenter objCType:@encode(Point2i)]];
            
            //        DWRingPosModel *savedModel = self.indexRingPosDic[[NSNumber numberWithInteger:j]];
            //        if (savedModel) {
            //            HandGesture *hg = new HandGesture;
            //            hg->rotationAngle[0] = savedModel.rotationAngleX;
            //            hg->rotationAngle[1] = savedModel.rotationAngleX;
            //            hg->rotationAngle[2] = savedModel.rotationAngleX;
            //            hg->ringAngle = savedModel.ringAngle;
            //            hg->ringCenter.x = savedModel.ringCenterX;
            //            hg->ringCenter.y = savedModel.ringCenterY;
            //            currentHand = hg;
            //        } else {
            //            [self processImage:image];
            //            DWRingPosModel *ringPosModel = [[DWRingPosModel alloc] init];
            //            ringPosModel.rotationAngleX = currentHand->rotationAngle[0];
            //            ringPosModel.rotationAngleY = currentHand->rotationAngle[1];
            //            ringPosModel.rotationAngleZ = currentHand->rotationAngle[2];
            //            ringPosModel.ringAngle = currentHand->ringAngle;
            //            ringPosModel.ringCenterX = currentHand->ringCenter.x;
            //            ringPosModel.ringCenterY = currentHand->ringCenter.y;
            //            [self.indexRingPosDic setObject:ringPosModel forKey:[NSNumber numberWithInteger:j]];
            //        }
            //        ppreviousHand = previousHand;
            //        previousHand = currentHand;
            //        currentHand = &hg;
            
            //        NSArray * angles = [self getCurrentAngle];
            
            if(!_angleArray)
                self.angleArray = [[NSMutableArray alloc]initWithCapacity:10];
            RotationAngle * rotationAngles = [[RotationAngle alloc] init];
            rotationAngles.x = currentHand->rotationAngle[0];
            double y = currentHand->rotationAngle[1];
            if (y < -M_PI/6.f) {
                y = -M_PI/6.f;
            } else if (y > M_PI/6.f) {
                y = M_PI/6.f;
            }
            rotationAngles.y = y;//currentHand->rotationAngle[1];
            rotationAngles.z = 0;//currentHand->rotationAngle[2];
            [self.angleArray addObject:rotationAngles];
        }
        
    }
    NSArray * smoothedAngles = self.angleArray;// [self smoothRotationAngle:self.angleArray];
    if(smoothedAngles)
    {
        for(int i = 0 ; i < smoothedAngles.count ; i++)
        {
            RotationAngle * angles = [smoothedAngles objectAtIndex:i];
            
            NSInteger x = 90 + radiusToDegree(angles.x);
            NSInteger y = 0 - radiusToDegree(angles.y);
            NSInteger z = radiusToDegree(angles.z);
            //      NSString *keyString = [NSString stringWithFormat:@"%d_%d_%d", x, y, z];
            NSString *keyString = [NSString stringWithFormat:@"MYIMG_ANG_x%ld_y%ld_z%ld.png", (long)x, (long)y, (long)z];
            
            [self.indexXYZDic setObject:keyString forKey:[NSNumber numberWithInteger:i]];
            
            id obj = [self.filenamePositionInfoDic objectForKey:keyString];
            if (!obj) {
                DLog(@"push %@", keyString);
                [self.rotationManager pushAngleX:x angleY:y angleZ:z];
                
            } else {
                DLog(@"skip key=%@", keyString);
            }
        }
    }

    
//  DLog(@"originalRingCenter : %@" ,self.ringCenterArray);
    [self printRingCenter];
    for(int i = 0 ; i<20 ; i++)
        [self smoothRingCenter];
 
    [self printRingCenter];
//  NSLog(@"smoothedRingCenter : %@" ,self.ringCenterArray);
    
    
    DLog(@"self.indexXYZDic=%@", self.indexXYZDic);

#if 0
    
    {
        for (NSInteger angleY = -30; angleY <= 30; ++angleY) {
            NSInteger x = 90;
            NSInteger y = angleY;
            NSInteger z = 0;
            NSString *keyString = [NSString stringWithFormat:@"MYIMG_ANG_x%ld_y%ld_z%ld.png", (long)x, (long)y, (long)z];
            
            id obj = [self.filenamePositionInfoDic objectForKey:keyString];
            if (!obj) {
                DLog(@"loudiaodepush %@", keyString);
                [self.rotationManager pushAngleX:x angleY:y angleZ:z];
            } else {
                DLog(@"skip key=%@", keyString);
            }
        }
    }
#endif
    
    if(j == self.labelSlider.slider.maximumValue)// || j == 15)
    {
        {
            NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent: @"indexRingPosDic"];
            
            NSDictionary *saveDic = [NSDictionary dictionaryWithDictionary:self.indexRingPosDic];
            BOOL saveRes = [NSKeyedArchiver archiveRootObject:saveDic toFile:betaCompressionDirectory];
            if (!saveRes)
            {
                DLog(@"save file failed!");
            }
            else
            {
                DLog(@"save file ok");
            }
        }
        
//        [self.rotationManager pushAngleX:0 angleY:0 angleZ:0];
        self.labelSlider.slider.enabled = NO;
        [self.rotationManager getOutput:^(NSMutableDictionary *outputDic) {
//            self.filenamePositionInfoDic = outputDic;
            // 将output的内容追加到filenamePositionInfoDic中去
            if (outputDic) {
                for (NSString *key in outputDic.allKeys) {
                    id obj = outputDic[key];
                    if (obj && key) {
                        [self.filenamePositionInfoDic setObject:obj forKey:key];
                    }
                }
            }
            DLog(@"filenamePositionInfoDic=%@", self.filenamePositionInfoDic);
            
            NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent: @"filenamePositionInfoDic"];
            
            
            
            
            NSDictionary *saveDic = [NSDictionary dictionaryWithDictionary:self.filenamePositionInfoDic];
            BOOL saveRes = [NSKeyedArchiver archiveRootObject:saveDic toFile:betaCompressionDirectory];
            if (!saveRes)
            {
                DLog(@"save file failed!");
            }
            else
            {
                DLog(@"save file ok");
            }
            
            for(int i = 1 ; i < self.labelSlider.slider.maximumValue; i++)
            {
                @autoreleasepool {
                    [self showImageAtIndex:i needAdjustDiff:YES];
                }
            }
            
            self.labelSlider.slider.enabled = YES;
        } controller:self];
        

    }
}
-(void)printRingCenter
{
    for(int i = 0 ; i< self.ringCenterArray.count ; i++)
    {
        Point2i ringcenter;
        [[self.ringCenterArray objectAtIndex:i] getValue:&ringcenter];
        DLog(@"ringCenter %d : x: %d, y :%d",i,ringcenter.x,ringcenter.y);
    }
}
#pragma mark -
#pragma mark get set

- (void)setTotalVideoFrame:(NSInteger)totalVideoFrame {
    self.labelSlider.slider.value = 0;
    self.labelSlider.slider.minimumValue = 0;
    self.labelSlider.slider.maximumValue = totalVideoFrame;
    _totalVideoFrame = totalVideoFrame;
}

#pragma mark -
#pragma mark misc function

- (NSString *)outputDir {
    return [NSString stringWithFormat:@"%@dir", self.videoPath];
}


#pragma mark -
#pragma mark LabelSlider's delegate

- (void)onValueChanged:(UISlider *)slider {
    DLog(@"slider");
    NSInteger j = (NSInteger) slider.value;
    if (self.canClick)
        self.canClick = NO;
    else
        return;
    [self.indicator startAnimating];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showImageAtIndex:j needAdjustDiff:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.indicator stopAnimating];
            self.canClick = YES;
        });
    });
}

- (void)onPicturesValueChanged:(UISlider *)slider {
    long value = (long)slider.value;
    NSString *pngPath = [NSString stringWithFormat:@"%@/output_%ld.jpg", [self outputDir], (long)value];
    self.title = [NSString stringWithFormat:@"%@ %zd/%zd", [self.videoPath lastPathComponent], value, self.totalVideoFrame];
    self.imageView.image = [UIImage imageWithContentsOfFile:pngPath];
}

- (void)onDiffValueChanged:(UISlider *)slider {
    if (self.diff != slider.value) {
        self.diff = slider.value;
        if (self.canClick)
            self.canClick = NO;
        else
            return;
        DLog(@"onDiffValueChanged diff=%zd", self.diff);
//        [self showImageAtIndex:self.labelSlider.slider.value];
        [self.indicator startAnimating];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showImageAtIndex:self.labelSlider.slider.value needAdjustDiff:NO];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.indicator stopAnimating];
                self.canClick = YES;
            });
        });
    }
}

- (void)onPreviousButtonClicked:(UIButton *)sender {
    static NSInteger i = 0;
    
    NSInteger j = (NSInteger)self.labelSlider.slider.value;
//    i = (j- 1 ) % self.totalVideoFrame ;
//    //    if (i > 14) {
//    //        i = 1;
//    //    }
    i = j - 1;
    if(i<0){
        i = self.totalVideoFrame;
    }
    
    self.labelSlider.slider.value = i;
    j = i;
    [self showImageAtIndex:j needAdjustDiff:YES];
}

- (void)onPickColorButtonClicked:(UIButton *)sender {
    SelectPointViewController *picker = [[SelectPointViewController alloc] init];
   
//    NSString *betaCompressionDirectory = nil;
//    betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    
//    NSLog(@"current filename=%@", betaCompressionDirectory);
    
    
    UIImage *image = [self getVideoImageAtIndex:0];
    
    picker.inputImage = image;
    [self presentViewController:picker animated:YES completion:NULL];
}

- (void)viewMovieAtUrl:(NSURL *)fileURL
{
    MPMoviePlayerViewController *playerController = [[MPMoviePlayerViewController alloc] initWithContentURL:fileURL];
    [playerController.view setFrame:self.view.bounds];
    [self presentMoviePlayerViewControllerAnimated:playerController];
    [playerController.moviePlayer prepareToPlay];
    [playerController.moviePlayer play];
    [self.view addSubview:playerController.view];
}

-(void)onMiddleButtonClicked:(UIButton *)sender
{
    ((UIButton *)sender).enabled = NO;
    [self.indicator startAnimating];
    if(!_frames)
    {
        self.frames = [[NSMutableArray alloc] init];

        for (NSInteger i = 1; i < self.labelSlider.slider.maximumValue; i++) {
            
            NSString *pngPath = [NSString stringWithFormat:@"%@/output_%ld.png", [self outputDir], (long)i];
//            NSString * pngPath = [self.videoPath stringByAppendingPathComponent:fileKeyName2];
            
            //         NSString * pngPath = [@"~/Desktop/ringvideo" stringByAppendingPathComponent:fileKeyName2];
            //        NSData *data = UIImagePNGRepresentation(resultImage);
            //        BOOL succ = [data writeToFile:pngPath atomically:YES];
//            UIImage * image = [UIImage imageWithContentsOfFile:pngPath];
            
            [self.frames addObject:pngPath];
        }
    }
//    if(!_movieMaker)
    {
//        NSString *fileKeyName2 = [NSString stringWithFormat:@"output_%ld.png", (long)1];
//        
//        NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//        NSString * pngPath = [self.videoPath stringByAppendingPathComponent:fileKeyName2];
        NSString *pngPath = [NSString stringWithFormat:@"%@/output_%ld.png", [self outputDir], (long)1];
        //         NSString * pngPath = [@"~/Desktop/ringvideo" stringByAppendingPathComponent:fileKeyName2];
        //        NSData *data = UIImagePNGRepresentation(resultImage);
        //        BOOL succ = [data writeToFile:pngPath atomically:YES];
        UIImage * image = [UIImage imageWithContentsOfFile:pngPath];
//        UIImage * image = [UIImage imageNamed:@"DW_PlusPressed1.png"];
        
        NSDictionary *settings = [CEMovieMaker videoSettingsWithCodec:AVVideoCodecH264 withWidth:image.size.width andHeight:image.size.height];
        self.movieMaker = [[CEMovieMaker alloc] initWithSettings:settings];
    }
    
    NSArray * frame = [self.frames objectsAtIndexes:[NSIndexSet indexSetWithIndex:0]];
    
    [self.movieMaker createMovieFromImages:[self.frames copy] withCompletion:^(NSURL *fileURL){
        [self.indicator stopAnimating];
        [self viewMovieAtUrl:fileURL];
        ((UIButton *)sender).enabled = YES;
    }];
}

- (void)onNextButtonClicked:(UIButton *)sender {
    if (self.canClick) {
        self.canClick = NO;
    } else {
        return;
    }
    [self.indicator startAnimating];
    
    static NSInteger i = 0;
    
    NSInteger j = (NSInteger)self.labelSlider.slider.value;
    i = (j ) % self.totalVideoFrame + 1;
//    if (i > 14) {
//        i = 1;
//    }
    self.labelSlider.slider.value = i;
    j = i;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showImageAtIndex:j needAdjustDiff:YES];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.15 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.indicator stopAnimating];
            self.canClick = YES;
        });
    });
}

static HandGesture *hg;

-(DWRotationManager *)rotationManager
{
    if(!_rotationManager)
    {
        _rotationManager = [DWRotationManager sharedManager];
    }
    return _rotationManager;
}

- (UIImage *)processImage:(UIImage *)image needAdjustDiff:(BOOL)needAdjustDiff {
    if (!image)
        return nil;
    TimeStamp(111);
    CFTimeInterval startTime = CACurrentMediaTime();
#if 0
    image = [ImageProcess correctImage:image];
    IplImage *ipImage = convertIplImageFromUIImage(image);
    Mat orignal_mat(ipImage, 1);
    Mat mat = orignal_mat.clone();
#else
    Mat orignal_mat = [image CVMat];
    rotate_image_90n(orignal_mat, orignal_mat, 180);
    Mat mat = orignal_mat.clone();
#endif
    CFTimeInterval endTime = CACurrentMediaTime();
    DLog(@"difftime = %g", (endTime - startTime) * 1000.f);
    TimeStamp(112);
    
    if(self.imageIndex == 1)
    {
        findROIColorInPalm(&mat);
    }
    DLog(@"width=%zd, height=%zd", image.size.width, image.size.height);
    
    if (hg) {
        delete hg;
    }
    hg = nil;//new HandGesture();
    
//    hg->index = (int)self.imageIndex;
    
    
    MyImage * myImage = nil;
    NSInteger i = self.diff;
    if (needAdjustDiff) {
        for (i = self.diff; i <= self.diffSlider.slider.maximumValue; ++i) {
            DLog(@"i=%zd", i);
            HandGesture *tmphg = new HandGesture();
            tmphg->index = (int)self.imageIndex;
            
            myImage = detectHand(&mat, *tmphg, (int)i * kStep);
            if (tmphg->isHand) {
                hg = tmphg;
                break;
            } else {
                delete tmphg;
                if (myImage) {
                    delete myImage;
                }
                mat = orignal_mat.clone();
                if(self.imageIndex == 1 )
                {
                    findROIColorInPalm(&mat);
                }
            }
        }
        if (!hg) {
            for (i = (NSInteger)self.diffSlider.slider.minimumValue; i < self.diff; ++i) {
                DLog(@"i=%zd", i);
                HandGesture *tmphg = new HandGesture();
                tmphg->index = (int)self.imageIndex;
                
                myImage = detectHand(&mat, *tmphg, (int)i * kStep);
                if (tmphg->isHand) {
                    hg = tmphg;
                    break;
                } else {
                    delete tmphg;
                    if (myImage) {
                        delete myImage;
                    }
                    mat = orignal_mat.clone();
                    if(self.imageIndex == 1 )
                    {
                        findROIColorInPalm(&mat);
                    }
//                    cvReleaseImage(&ipImage);
//                    ipImage = convertIplImageFromUIImage(image);
                }
            }
        }
    }
    self.diff = i;
    if (!hg) {
        i = self.diff;
        DLog(@"i=%zd", i);
        HandGesture *tmphg = new HandGesture();
        tmphg->index = (int)self.imageIndex;
        myImage = detectHand(&mat, *tmphg, (int)i * kStep);
        hg = tmphg;
    }
    self.diffSlider.slider.value = self.diff;
    currentHand = hg;
    
//    if(currentHand->isHand)
    {
       DLog(@"width=%d, height=%d", myImage->src.cols, myImage->src.rows);
       IplImage qImg;
       qImg = IplImage(myImage->src);
       
       IplImage *ret1 = cvCreateImage(cvGetSize(&qImg), IPL_DEPTH_8U, 3);
       cvCvtColor(&qImg, ret1, CV_BGR2RGB);
       UIImage *outputImage = convertUIImageFromIplImage(ret1);
       delete myImage;
//       cvReleaseImage(&ipImage);
       cvReleaseImage(&ret1);
       return outputImage;
    }
//    else {
//      return image;
//    }
    TimeStamp(113);
    
}

//- (void)showImageAtIndex:(NSInteger)j {
//    self.title = [NSString stringWithFormat:@"%zd", j];
//    
//    UIImage *image = [self getVideoImageAtIndex:j];
//    self.imageIndex = j;
//    
//    if(!image)
//        return;
//    
//    image = [self processImage:image needAdjustDiff:YES];
//    
//    if(!image)
//        return;
//    
//    NSDictionary * outputDic = self.filenamePositionInfoDic;
//    
//    if(!outputDic) {
//        return;
//    }
//    
//    NSString *fileKeyName = self.indexXYZDic[[NSNumber numberWithInteger:j]];
//    fileKeyName = nil;
//    DWRingPositionInfo * info = [outputDic objectForKey:fileKeyName];
//    
//    UIImage * ringImage = [self getImage:j];
//    
//    double ratio = ringImage.size.height / ringImage.size.width;
//    
//    ringImage = [ImageProcess correctImage:ringImage toFitIn:CGSizeMake(320, 320 * ratio)];
//    
//    CGFloat ringAngle = currentHand->ringAngle;
//    CGFloat shrinkRatio = currentHand->ringWidth / 80.f;
//    
//    ringImage = [self clipImage:ringImage ringPosition:info withRadian:ringAngle shrinkRatio:shrinkRatio];
//    
//    UIImage * resultImage = [self mergeFrontImage:ringImage backImage:image];
//    self.imageView.image = resultImage;
//    
//    // 将每一帧的图片保存到documents目录下
//#if 0
//    {
//        NSString *pngPath = [NSString stringWithFormat:@"%@_output_%ld.jpg", self.videoPath, (long)j];
//        NSData *data = UIImageJPEGRepresentation(resultImage, 0.8);
//        BOOL succ = [data writeToFile:pngPath atomically:YES];
//        if (!succ) {
//            NSLog(@"save failed, %@", pngPath);
//        }
//    }
//#endif
//}

- (void)showImageAtIndex:(NSInteger)j needAdjustDiff:(BOOL)needAdjustDiff {
//    self.title = [NSString stringWithFormat:@"%zd", j];
    self.title = [NSString stringWithFormat:@"%@ %zd/%zd", [self.videoPath lastPathComponent], j, self.totalVideoFrame];
    UIImage *image = [self getVideoImageAtIndex:j];
    self.imageIndex = j;

    image = [self processImage:image needAdjustDiff:needAdjustDiff];
    
    if(!image)
        return;
    
    NSDictionary * outputDic = self.filenamePositionInfoDic;
    
    if(!outputDic) {
        return;
    }
    
    NSString *fileKeyName = self.indexXYZDic[[NSNumber numberWithInteger:j]];
//    fileKeyName = nil;
     DLog(@"ringfileKeyName=%@", fileKeyName);
    DWRingPositionInfo * info = [outputDic objectForKey:fileKeyName];

    UIImage * ringImage = [self getImage:j];
 
    double ratio = ringImage.size.height / ringImage.size.width;
 
    if(currentHand->isHand){
        ringImage = [ImageProcess correctImage:ringImage toFitIn:CGSizeMake(320, 320 * ratio)];
    }else{
        ringImage = nil;
    }
    CGFloat ringAngle = currentHand->ringAngle;
    CGFloat shrinkRatio = currentHand->ringWidth / 80.f;
    
    ringImage = [self clipImage:ringImage ringPosition:info withRadian:ringAngle shrinkRatio:shrinkRatio];
    
    UIImage * resultImage = [self mergeFrontImage:ringImage backImage:image];
    self.imageView.image = resultImage;
    
    // 将每一帧的图片保存到documents目录下
#if 1
    {
        NSString *pngPath = [NSString stringWithFormat:@"%@/output_%ld.png", [self outputDir], (long)j];
        NSData *data = UIImageJPEGRepresentation(resultImage, 0.8);
        BOOL succ = [data writeToFile:pngPath atomically:YES];
        if (!succ) {
            DLog(@"save failed, %@", pngPath);
        }
    }
#endif
}

-(UIImage *)getImage:(NSInteger)index
{
    if(index <= 0)
        return nil;
    
    NSString *fileKeyName = self.indexXYZDic[[NSNumber numberWithInteger:index]];
    if (!fileKeyName) {
        return [self getImage:index - 1];
    }

    NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString * pngPath = [betaCompressionDirectory stringByAppendingPathComponent:fileKeyName];
    UIImage *ringImage = [UIImage imageNamed:fileKeyName];
    if (!ringImage) {
        ringImage = [UIImage imageWithContentsOfFile:pngPath];
    }
    
    if(!ringImage) {
        return [self getImage:index - 1];
    } else {
        return ringImage;
    }
}

-(UIImage *)clipImage:(UIImage *)image ringPosition:(DWRingPositionInfo *) position withRadian:(CGFloat)radian shrinkRatio:(CGFloat)shrinkRatio
{
    if (!image) {
        return nil;
    }
//    CGPoint center = position.centerPoint;
    CGPoint maxPoint = position.maxPoint;
    CGPoint minPoint = position.minPoint;
    
    CGRect rect = CGRectMake(minPoint.x, image.size.height - minPoint.y - (maxPoint.y - minPoint.y ) ,maxPoint.x - minPoint.x -5 , maxPoint.y - minPoint.y + 10);
    
    CGSize size = image.size;
    UIGraphicsBeginImageContext(size);
    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], rect);
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    //    CGContextTranslateCTM(ctx, size.width/2, size.height/2);
    //    CGContextRotateCTM(ctx, M_PI/2);
    CGContextDrawImage(ctx, CGRectMake(-size.width/2,-size.height/2,size.width, size.height), imageRef);
    
    //    CGContextTranslateCTM(ctx, -size.width/2, -size.height/2);
    
    //    CGContextDrawImage(, , image);UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    UIImage * img = [UIImage imageWithCGImage:imageRef];
    img = [self rotateImage:img withRadian:radian shrinkRatio:shrinkRatio];
    CGImageRelease(imageRef);
    return img;
}



- (UIImage *)rotateImage:(UIImage *)image withRadian:(CGFloat)radian shrinkRatio:(CGFloat)shrinkRatio
{
    if (!image) {
        return nil;
    }
//    CGFloat shirinkRatio = currentHand->ringWidth / 80;
    // Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    //CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degree));
    CGAffineTransform t = CGAffineTransformMakeRotation(radian);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
//    [rotatedViewBox release];
    
    rotatedSize.width *= shrinkRatio;
    rotatedSize.height *= shrinkRatio;
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    // Rotate the image context
    //CGContextRotateCTM(bitmap, DegreesToRadians(degree));
    CGContextRotateCTM(bitmap, radian);
    
    CGSize drawSize = image.size;
    drawSize.width *= shrinkRatio;
    drawSize.height *= shrinkRatio;

    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
//    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
    CGContextDrawImage(bitmap, CGRectMake(-drawSize.width / 2, -drawSize.height / 2, drawSize.width, drawSize.height), [image CGImage]);
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(UIImage *)rotateImage:(UIImage *)aImage angle:(double)angle
{
    CGImageRef imgRef = aImage.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    UIGraphicsBeginImageContext(bounds.size);
    transform = CGAffineTransformRotate(transform, angle);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextConcatCTM(context, transform);
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return imageCopy;
}


- (UIImage *)mergeFrontImage:(UIImage *) frontImage backImage:(UIImage *)backimage
{
    UIGraphicsBeginImageContext(backimage.size);
    [backimage drawAtPoint:CGPointMake(0,0)];
    Point2i ringcenter = currentHand->ringCenter;
//    Point2i ringcenter;
 
//    int index = self.imageIndex / 2 * 2;
//    NSInteger index = self.imageIndex - 1;
//     [[self.ringCenterArray objectAtIndex:index] getValue:&ringcenter];
    
    [frontImage drawAtPoint:CGPointMake(ringcenter.x - frontImage.size.width/2,ringcenter.y -frontImage.size.height/2)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)getAllImageFromVideo {
//    NSString *betaCompressionDirectory = [NSString stringWithFormat:@"%@/MYIMG_ORI%zd.JPG", self.videoPath, 0];
//    {
//        int i = 156;
//        NSString *betaCompressionDirectory = self.videoPath;//[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//        betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"_MYIMG_ORI%ld.JPG", (long)i-1]];
//        if ([[NSFileManager defaultManager] fileExistsAtPath:betaCompressionDirectory]) {
//            self.totalVideoFrame = i;
//            if (!self.rotationManager) {
//            }
//            return;
//        }
//    }

    NSString *path = self.videoPath;//[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Movie12347.m4v"];
    NSString *fileName = [path lastPathComponent];
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:fileName];
    if ([value integerValue] > 0) {
        self.totalVideoFrame = [value integerValue];
        self.picturesSlider.slider.maximumValue = self.totalVideoFrame;
        return;
    }
    
    DWVideoDecoding *videoEncoder = [[DWVideoDecoding alloc] initWithMoviePath:path];
    self.videoEncoder = videoEncoder;
    [SVProgressHUD showWithStatus:@"Processing..."];
    UIImage *image = nil;
    //    image = [self.videoEncoder fetchOneFrame];
    NSInteger i = 0;
    BOOL flag = YES;
    while (flag) {
        @autoreleasepool {
            image = [self.videoEncoder fetchOneFrame];
            if (!image) {
                break;
            }
//            image = [self rotateImage:image withRadian:(M_PI_4 * 2 + M_PI_4 * 2 + M_PI_4 * 2 + M_PI_4 * 2)   shrinkRatio:1.f];
//            NSString *betaCompressionDirectory = self.videoPath;//[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            NSString *betaCompressionDirectory = [NSString stringWithFormat:@"%@/MYIMG_ORI%zd.JPG", [self outputDir], i];
            DLog(@"get image=%@", betaCompressionDirectory);
            NSData *imageData = UIImageJPEGRepresentation(image, 1.0);
            BOOL ret = [imageData writeToFile:betaCompressionDirectory atomically:YES];
            if (!ret)
                DLog(@"writedata failed:%@", betaCompressionDirectory);
            ++i;
        }
    }
    self.totalVideoFrame = i;
    self.picturesSlider.slider.maximumValue = self.totalVideoFrame;
    
    [[NSUserDefaults standardUserDefaults] setObject:@(i) forKey:fileName];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SVProgressHUD dismiss];
    return;
}

@end
