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
@interface FirstViewController () {
    
    HandGesture * currentHand;
}

@property (nonatomic, retain) UIImageView *imageView;

@property (nonatomic, retain) LabelSlider *labelSlider;

@property (nonatomic, strong) DWVideoDecoding *videoEncoder;

@property (nonatomic, assign) NSInteger totalVideoFrame;


@property (nonatomic, assign) int imageIndex;


@property (nonatomic, strong) DWRotationManager* rotationManager;

@property (nonatomic, strong) NSMutableDictionary *filenamePositionInfoDic;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Do any additional setup after loading the view, typically from a nib.
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    UIImage *image = [UIImage imageNamed:@"IMG_0835.JPG"];
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    LabelSlider *labelSlider = [[LabelSlider alloc] initWithFrame:CGRectMake(0, 44 + 20 + 25, self.view.bounds.size.width, 20)];
    [labelSlider.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [labelSlider.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventTouchUpOutside];
    labelSlider.label.text = nil;
    labelSlider.slider.minimumValue = 0.0f;
    labelSlider.slider.maximumValue = 1.0f;
    [self.view addSubview:labelSlider];
    self.labelSlider = labelSlider;
    
    UIButton *nextButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    nextButton.frame = CGRectMake(self.view.frame.size.width - 20, self.view.frame.size.height - 80, 20, 20);
    [nextButton addTarget:self action:@selector(onNextButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:nextButton];
    
    
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self getAllImageFromVideo];
    });
    
    [self showImageAtIndex:1];
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

- (void)onNextButtonClicked:(UIButton *)sender {
    static NSInteger i = 0;
    
    NSInteger j = (NSInteger)self.labelSlider.slider.value;
    i = (j + 1) % 100;
    self.labelSlider.slider.value = i;
    j = i;
    [self showImageAtIndex:j];
}
 static HandGesture hg;

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
    //    CGSize newSize = CGSizeMake(image.size.width / 4.0, image.size.height / 4.0);
    //    image = [image resizeImageContext:nil size:newSize];
    image = [ImageProcess correctImage:image];
    IplImage *ipImage = convertIplImageFromUIImage(image);
    
    NSLog(@"width=%d, height=%d", ipImage->width, ipImage->height);
    
    hg = HandGesture();
    
    hg.index = self.imageIndex;
    MyImage * myImage = detectHand(ipImage, hg);
    currentHand = &hg;
//    Point2i ringStart = hg.ringPosition[0];
//    Point2i ringEnd = hg.ringPosition[1];
    
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
//    NSString *betaCompressionDirectory = nil;
//    betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
//    betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"MYIMG_ORI%ld.JPG", (long)j]];
    NSString *lastName = [self.videoPath lastPathComponent];
    NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_MYIMG_ORI%ld.JPG", lastName, (long)j]];
    
//    NSString *fileName = [NSString stringWithFormat:@"MYIMG_SMALL%zd.JPG", j];
    NSLog(@"current filename=%@", betaCompressionDirectory);
//    image = [UIImage imageNamed:fileName];
    
    self.imageIndex = j;
    
    image = [UIImage imageWithContentsOfFile:betaCompressionDirectory];
//    self.imageView.image = [self processImage:image];
    if(!image)
        return;
    

    image = [self processImage:image];
    self.imageView.image = image;
    if (!_rotationManager) {
        [self.rotationManager pushAngleX:currentHand->rotationAngle[0] angleY:currentHand->rotationAngle[1] angleZ:currentHand->rotationAngle[2]];
        [self.rotationManager getOutput:^(NSMutableDictionary *outputDic) {
            
            
            //            NSLog(@"key: %@ value: %@", key, dict[key]);
            if (outputDic.allKeys.count > 1) {
                NSString * pngName = [outputDic.allKeys objectAtIndex:1];
                DWRingPositionInfo * info = [outputDic objectForKey:pngName];
                
                NSString * pngPath = [betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:pngName, (long)j]];
                UIImage * ringImage = [UIImage imageWithContentsOfFile:pngPath];
                
                
                //        UIImage * ringImage = [UIImage imageNamed:@"ring.png"];
                
                ringImage = [self clipImage:ringImage ringPosition:info];
                //
                UIImage * resultImage = [self mergeFrontImage:ringImage backImage:image];
                self.imageView.image = resultImage;
            }
            
            
        } controller:self.navigationController];
        
    }
//    NSString *key = [self.filenamePositionInfoDic allKeys].firstObject;
    

}

-(UIImage *)clipImage:(UIImage *)image ringPosition:(DWRingPositionInfo *) position
{

//    key:MYIMG_ANG_x90.000000_y0.000000_z0.000000.png, value:center:NSPoint: {160, 243.27763}, min:NSPoint: {123.66412, 244.02368}, max:NSPoint: {197.71791, 325.49683}
//    CGRect rect = CGRectMake(123, image.size.height - 210, 78, 28);
    
    CGPoint center = position.centerPoint;
    CGPoint maxPoint = position.maxPoint;
    CGPoint minPoint = position.minPoint;
    
    CGRect rect = CGRectMake(minPoint.x, minPoint.y ,maxPoint.x - minPoint.x , maxPoint.y - minPoint.y);
    
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
    // Calculate the size of the rotated view's containing box for our drawing space
    UIView *rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    //CGAffineTransform t = CGAffineTransformMakeRotation(DegreesToRadians(degree));
    CGAffineTransform t = CGAffineTransformMakeRotation(radian);
    rotatedViewBox.transform = t;
    CGSize rotatedSize = rotatedViewBox.frame.size;
//    [rotatedViewBox release];
    
    // Create the bitmap context
    UIGraphicsBeginImageContext(rotatedSize);
    CGContextRef bitmap = UIGraphicsGetCurrentContext();
    
    // Move the origin to the middle of the image so we will rotate and scale around the center.
    CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
    
    // Rotate the image context
    //CGContextRotateCTM(bitmap, DegreesToRadians(degree));
    CGContextRotateCTM(bitmap, radian);
    
    // Now, draw the rotated/scaled image into the context
    CGContextScaleCTM(bitmap, 1.0, -1.0);
    CGContextDrawImage(bitmap, CGRectMake(-image.size.width / 2, -image.size.height / 2, image.size.width, image.size.height), [image CGImage]);
    
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
    [frontImage drawAtPoint:CGPointMake(ringcenter.x - frontImage.size.width/2,ringcenter.y -frontImage.size.height/2)];
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

- (void)getAllImageFromVideo {
    {
        int i = 156;
        NSString *lastName = [self.videoPath lastPathComponent];
        NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
        betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_MYIMG_ORI%ld.JPG", lastName, (long)i-1]];
        if ([[NSFileManager defaultManager] fileExistsAtPath:betaCompressionDirectory]) {
            self.totalVideoFrame = i;
            if (!_rotationManager) {
                self.rotationManager = [DWRotationManager sharedManager];
                [self.rotationManager pushAngleX:90 angleY:0 angleZ:0];
                [self.rotationManager getOutput:^(NSMutableDictionary *outputDic) {
                    self.filenamePositionInfoDic = outputDic;
                    NSLog(@"outputDic=%@", outputDic);
                    
                } controller:self];
            }
            return;
        }
    }
   
    NSString *path = self.videoPath;//[[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"Movie12347.m4v"];
//    path = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"MyVideo1425481767.MOV"];
    //12345 keyishen的手
    //12346 jerry的手
    //12347 jerry的手on sofa
    
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
            //        NSString *parentDir = [NSHomeDirectory()stringByAppendingPathComponent:@"Documents/Movie"];
            NSString *lastName = [self.videoPath lastPathComponent];
            NSString *betaCompressionDirectory = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
            betaCompressionDirectory = [betaCompressionDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@_MYIMG_ORI%ld.JPG", lastName, (long)i]];
            
            NSLog(@"get image=%@", betaCompressionDirectory);
            //        betaCompressionDirectory = [parentDir stringByAppendingString:[NSString stringWithFormat:@"_%f.m4v", [[NSDate date] timeIntervalSince1970]]];
            //        betaCompressionDirectory = [parentDir stringByAppendingString:@".m4v"];
//            double scale = 1.0f;
//            CGSize newSize = CGSizeMake(image.size.width/scale, image.size.height/scale);
//            image = [image resizeImageContext:nil size:newSize];
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
