//
//  FirstViewController.m
//  catRing
//
//  Created by sky on 15/2/17.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "FirstViewController.h"

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
// utility

// video decoding
#import "DWVideoDecoding.h"
// video decoding

#import "DWRotationManager.h"

#import "ImageProcess.h"

#import "DWRingPositionInfo.h"
#import "DWRingPosModel.h"

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
}

@property (nonatomic, retain) UIImageView *imageView;

@property (nonatomic, retain) LabelSlider *labelSlider;

@property (nonatomic, strong) DWVideoDecoding *videoEncoder;

@property (nonatomic, assign) NSInteger totalVideoFrame;

@property (nonatomic, retain) NSMutableArray * angleArray;
@property (nonatomic, retain) NSMutableArray * ringCenterArray;
@property (nonatomic, assign) int imageIndex;

@property (nonatomic, strong) UIActivityIndicatorView *indicator;

@property (nonatomic, strong) DWRotationManager* rotationManager;

@property (nonatomic, strong) NSMutableDictionary *filenamePositionInfoDic;

@property (nonatomic, strong) NSMutableDictionary *indexXYZDic;
@property (nonatomic, strong) NSMutableDictionary *indexRingPosDic;
@end

@implementation FirstViewController

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
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    UIImage *image = [UIImage imageNamed:@"IMG_0835.JPG"];
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    LabelSlider *labelSlider = [[LabelSlider alloc] initWithFrame:CGRectMake(0, 25, self.view.bounds.size.width, 20)];
    [labelSlider.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [labelSlider.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventTouchUpOutside];
    labelSlider.label.text = nil;
    labelSlider.slider.minimumValue = 0.0f;
    labelSlider.slider.maximumValue = 1.0f;
    [self.view addSubview:labelSlider];
    self.labelSlider = labelSlider;
    
    UIButton *previousButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    previousButton.frame = CGRectMake(20, self.view.frame.size.height - 80, 20, 20);
    [previousButton addTarget:self action:@selector(onPreviousButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:previousButton];
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    nextButton.frame = CGRectMake(self.view.frame.size.width - 20, self.view.frame.size.height - 80, 20, 20);
    [nextButton addTarget:self action:@selector(onNextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
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
    if (firstTime) {
        firstTime = NO;
        [self.indicator startAnimating];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self getAllImageFromVideo];
            [self processAllImages];
            [self.indicator stopAnimating];
            [self showImageAtIndex:1];
        });
    }

    
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
    
    for (int i = 1 ; i<array.count -1 ; i++)
    {
        Point2i previousCenter;
        [[array objectAtIndex:i-1] getValue:&previousCenter];
        
        Point2i currentCenter;
        [[array objectAtIndex:i] getValue:&currentCenter];
        
        Point2i nextCenter;
        [[array objectAtIndex:i+1] getValue:&nextCenter];
        
        Point2i newCenter;
        
        newCenter.x = (previousCenter.x + currentCenter.x + nextCenter.x) /3;
        newCenter.y = (previousCenter.y + currentCenter.y + nextCenter.y) /3;
        [result addObject:[NSValue valueWithBytes:&newCenter objCType:@encode(Point2i)]];
    }
    self.ringCenterArray = result;
}

-(NSMutableArray *)smoothRotationAngle:(NSArray *)array
{
    [self reduceDefectForRotationAngle:array];
    
    NSMutableArray * result = [[NSMutableArray alloc] initWithCapacity:array.count];
    for (int i = 1 ; i<array.count -1 ; i++)
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
        NSLog(@"oringinal angles: %f, %f ,%f", currentAngles.x,currentAngles.y,currentAngles.z);
    }
    
    for(int i = 0 ; i<result.count  ; i++)
    {
        RotationAngle * resultAngles = [result objectAtIndex:i];
        NSLog(@"smoothed angles: %f, %f ,%f", resultAngles.x,resultAngles.y,resultAngles.z);
    }
    return result;
}
-(void)processAllImages
{
    __block NSString *betaCompressionDirectory = nil;
    betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    //    betaCompressionDirectory = ];
    
    //    NSString *fileName = [NSString stringWithFormat:@"MYIMG_SMALL%zd.JPG", j];
    NSLog(@"current filename=%@", betaCompressionDirectory);
    //    image = [UIImage imageNamed:fileName];
    
    
//    self.filenamePositionInfoDic = [[NSMutableDictionary alloc ] initWithContentsOfFile:  [betaCompressionDirectory stringByAppendingPathComponent: @"filenamePositionInfoDic"]];

    
//    [self.rotationManager pushAngleX:90 angleY:0 angleZ:0];
//    [self.rotationManager pushAngleX:90 angleY:0 angleZ:0];
    
//    if (self.indexRingPosDic.allKeys.count > 10)
//        return;
    
    int j;
    for( j = 1 ; j < self.labelSlider.slider.maximumValue; j++)// && j < 15; j++)
    {
        @autoreleasepool {
            
        self.title = [NSString stringWithFormat:@"%zd", j];
        //    [self wmcSetNavigationBarTitleStyle];
        
        UIImage *image = nil;
        //    NSString *fileName = [NSString stringWithFormat:@"MYIMG_ORI%zd.JPG", j];
        __block NSString *betaCompressionDirectory = nil;
        betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        //    betaCompressionDirectory = ];
        
        //    NSString *fileName = [NSString stringWithFormat:@"MYIMG_SMALL%zd.JPG", j];
        NSLog(@"current filename=%@", betaCompressionDirectory);
        //    image = [UIImage imageNamed:fileName];
        
        self.imageIndex = j;
        
        image = [UIImage imageWithContentsOfFile:[betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MYIMG_ORI%ld.JPG", (long)j]]];
        //    self.imageView.image = [self processImage:image];
        
        if(!image)
            return;
        
        [self processImage:image];
            
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
        rotationAngles.y = currentHand->rotationAngle[1];
        rotationAngles.z = currentHand->rotationAngle[2];
        [self.angleArray addObject:rotationAngles];
           }
    }
    NSMutableArray * smoothedAngles = [self smoothRotationAngle:self.angleArray];
    self.angleArray = smoothedAngles;
    if(smoothedAngles)
    {
        for(int i = 0 ; i < smoothedAngles.count ; i++)
        {
            RotationAngle * angles = [smoothedAngles objectAtIndex:i];
            
            NSInteger x = 90 + radiusToDegree(angles.x);
            NSInteger y = 0 - radiusToDegree(angles.y);
            NSInteger z = radiusToDegree(angles.z);
            //      NSString *keyString = [NSString stringWithFormat:@"%d_%d_%d", x, y, z];
            NSString *keyString = [NSString stringWithFormat:@"MYIMG_ANG_x%d_y%d_z%d.png", x, y, z];
            
            [self.indexXYZDic setObject:keyString forKey:[NSNumber numberWithInteger:i]];
            
            id obj = [self.filenamePositionInfoDic objectForKey:keyString];
            if (!obj) {
                NSLog(@"push %@", keyString);
                [self.rotationManager pushAngleX:x angleY:y angleZ:z];
                
            } else {
                NSLog(@"skip key=%@", keyString);
            }
        }
    }
    
//    NSLog(@"originalRingCenter : %@" ,self.ringCenterArray);
    [self printRingCenter];
//    [self smoothRingCenter];
//    [self smoothRingCenter];
    [self printRingCenter];
//    NSLog(@"smoothedRingCenter : %@" ,self.ringCenterArray);
    
    if(j == self.labelSlider.slider.maximumValue)// || j == 15)
    {
        {
            NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent: @"indexRingPosDic"];
            
            NSDictionary *saveDic = [NSDictionary dictionaryWithDictionary:self.indexRingPosDic];
            BOOL saveRes = [NSKeyedArchiver archiveRootObject:saveDic toFile:betaCompressionDirectory];
            if (!saveRes)
            {
                NSLog(@"save file failed!");
            }
            else
            {
                NSLog(@"save file ok");
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
            NSLog(@"filenamePositionInfoDic=%@", self.filenamePositionInfoDic);
            
            NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent: @"filenamePositionInfoDic"];
            self.labelSlider.slider.enabled = YES;
            
            NSDictionary *saveDic = [NSDictionary dictionaryWithDictionary:self.filenamePositionInfoDic];
            BOOL saveRes = [NSKeyedArchiver archiveRootObject:saveDic toFile:betaCompressionDirectory];
            if (!saveRes)
            {
                NSLog(@"save file failed!");
            }
            else
            {
                NSLog(@"save file ok");
            }
        } controller:self];
        

    }
}
-(void)printRingCenter
{
    for(int i = 0 ; i< self.ringCenterArray.count ; i++)
    {
        Point2i ringcenter;
        [[self.ringCenterArray objectAtIndex:i] getValue:&ringcenter];
        NSLog(@"ringCenter %d : x: %d, y :%d",i,ringcenter.x,ringcenter.y);
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
#pragma mark LabelSlider's delegate

- (void)onValueChanged:(UISlider *)slider {
    NSLog(@"slider");
    NSInteger j = (NSInteger) slider.value;
    [self showImageAtIndex:j];
}

- (void)onPreviousButtonClicked:(UIButton *)sender {
    static NSInteger i = 0;
    
    NSInteger j = (NSInteger)self.labelSlider.slider.value;
    i = (j - 1) % self.totalVideoFrame;
    //    if (i > 14) {
    //        i = 1;
    //    }
    self.labelSlider.slider.value = i;
    j = i;
    [self showImageAtIndex:j];
}

- (void)onNextButtonClicked:(UIButton *)sender {
    static NSInteger i = 0;
    
    NSInteger j = (NSInteger)self.labelSlider.slider.value;
    i = (j + 1) % self.totalVideoFrame;
//    if (i > 14) {
//        i = 1;
//    }
    self.labelSlider.slider.value = i;
    j = i;
    [self showImageAtIndex:j];
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

- (UIImage *)processImage:(UIImage *)image {
    if (!image)
        return nil;

    image = [ImageProcess correctImage:image];
    IplImage *ipImage = convertIplImageFromUIImage(image);
    
    NSLog(@"width=%d, height=%d", ipImage->width, ipImage->height);
    
    hg = new HandGesture();
    
    hg->index = self.imageIndex;
    MyImage * myImage = detectHand(ipImage, *hg);
    
    currentHand = hg;
    
    NSLog(@"width=%d, height=%d", myImage->src.cols, myImage->src.rows);
    IplImage qImg;
    qImg = IplImage(myImage->src);
    
    IplImage *ret1 = cvCreateImage(cvGetSize(&qImg), IPL_DEPTH_8U, 3);
    cvCvtColor(&qImg, ret1, CV_BGR2RGB);
    UIImage *outputImage = convertUIImageFromIplImage(ret1);
    delete myImage;
    cvReleaseImage(&ipImage);
    cvReleaseImage(&ret1);
    return outputImage;
}

- (void)showImageAtIndex:(NSInteger)j {
    self.title = [NSString stringWithFormat:@"%zd", j];
//    [self wmcSetNavigationBarTitleStyle];
    
    UIImage *image = nil;
//    NSString *fileName = [NSString stringWithFormat:@"MYIMG_ORI%zd.JPG", j];
    NSString *betaCompressionDirectory = nil;
    betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];

    NSLog(@"current filename=%@", betaCompressionDirectory);
    
    self.imageIndex = j;
    
    image = [UIImage imageWithContentsOfFile:[betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MYIMG_ORI%ld.JPG", (long)j]]];
    
    if(!image)
        return;
    
    image = [self processImage:image];

    NSDictionary * outputDic = self.filenamePositionInfoDic;
    
    if(!outputDic)
        return;
    
    NSString *fileKeyName = self.indexXYZDic[[NSNumber numberWithInteger:j]];
    DWRingPositionInfo * info = [outputDic objectForKey:fileKeyName];

    UIImage * ringImage = [self getImage:j];
    
    double ratio = ringImage.size.height / ringImage.size.width;
 
    ringImage = [ImageProcess correctImage:ringImage toFitIn:CGSizeMake(320, 320 * ratio)];

    ringImage = [self clipImage:ringImage ringPosition:info];
    
    UIImage * resultImage = [self mergeFrontImage:ringImage backImage:image];
    self.imageView.image = resultImage;
}

-(UIImage *)getImage:(NSInteger)index
{
    if(index <= 0)
        return nil;
    
    NSString *fileKeyName = self.indexXYZDic[[NSNumber numberWithInteger:index]];
    if (!fileKeyName) {
        return [self getImage:index - 1];;
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

-(UIImage *)clipImage:(UIImage *)image ringPosition:(DWRingPositionInfo *) position
{
 
    
 
    //    key:MYIMG_ANG_x90.000000_y0.000000_z0.000000.png, value:center:NSPoint: {160, 243.27763}, min:NSPoint: {123.66412, 244.02368}, max:NSPoint: {197.71791, 325.49683}
    //    CGRect rect = CGRectMake(123, image.size.height - 210, 78, 28);
    
    CGPoint center = position.centerPoint;
    CGPoint maxPoint = position.maxPoint;
    CGPoint minPoint = position.minPoint;
    
    CGRect rect = CGRectMake(minPoint.x, image.size.height - minPoint.y - (maxPoint.y - minPoint.y ) ,maxPoint.x - minPoint.x -5 , maxPoint.y - minPoint.y + 10);
    
    
#if 0
    NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MYIMG_ANG_x90.000000_y0.000000_z0.000000.png"]];
    image = [UIImage imageWithContentsOfFile:betaCompressionDirectory];
    rect = CGRectMake(123, image.size.height - 325.49683, 197.71791 - 123.66412, 325.49683 - 244.02368);
    // 区域还没挑对
#endif
    
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
    img = [self rotateImage:img withRadian:currentHand->ringAngle];
    
    return img;
}

- (UIImage *)rotateImage:(UIImage *)image withRadian:(CGFloat)radian
{
    double shirinkRatio = currentHand->ringWidth / 80;
    
    // Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height * shirinkRatio)];
    //CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degree));
    CGAffineTransform t = CGAffineTransformMakeRotation(radian);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
//    [rotatedViewBox release];
    
    rotatedSize.width *= shirinkRatio;
    rotatedSize.height *= shirinkRatio;
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    // Rotate the image context
    //CGContextRotateCTM(bitmap, DegreesToRadians(degree));
    CGContextRotateCTM(bitmap, radian);
    
    CGSize drawSize = image.size;
    drawSize.width *= shirinkRatio;
    drawSize.height *= shirinkRatio;
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
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
//    Point2i ringcenter = currentHand->ringCenter;
    Point2i ringcenter;
     [[self.ringCenterArray objectAtIndex:self.imageIndex] getValue:&ringcenter];
    
    [frontImage drawAtPoint:CGPointMake(ringcenter.x - frontImage.size.width/2,ringcenter.y -frontImage.size.height/2)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)getAllImageFromVideo {
    {
        int i = 156;
        NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MYIMG_ORI%ld.JPG", (long)i-1]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:betaCompressionDirectory]) {
            self.totalVideoFrame = i;
            if (!self.rotationManager) {
                self.rotationManager = [DWRotationManager sharedManager];
                [self.rotationManager pushAngleX:90 angleY:0 angleZ:0];
                [self.rotationManager pushAngleX:90 angleY:10 angleZ:0];
                [self.rotationManager pushAngleX:90 angleY:20 angleZ:0];
                [self.rotationManager pushAngleX:90 angleY:30 angleZ:0];
                [self.rotationManager pushAngleX:90 angleY:-30 angleZ:0];
                [self.rotationManager getOutput:^(NSMutableDictionary *outputDic) {
                    self.filenamePositionInfoDic = outputDic;
                    NSLog(@"outputDic=%@", outputDic);
                    
                } controller:self];
            }
            return;
        }
    }
   
    NSString *path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Movie12347.m4v"];
    
    NSNumber *value = [[NSUserDefaults standardUserDefaults] objectForKey:path];
    if ([value integerValue] > 0) {
        self.totalVideoFrame = [value integerValue];
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
                flag = NO;
                break;
            }
            NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MYIMG_ORI%ld.JPG", (long)i]];
            NSLog(@"get image=%@", betaCompressionDirectory);
            NSData *imageData = UIImagePNGRepresentation(image);
            [imageData writeToFile:betaCompressionDirectory atomically:YES];
            ++i;
        }
    }
    self.totalVideoFrame = i;
    [[NSUserDefaults standardUserDefaults] setObject:@(i) forKey:path];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [SVProgressHUD dismiss];
    return;
}

@end
