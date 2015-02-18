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
// UI


// algorithm
#import <opencv2/highgui/ios.h>
#import "mymain.hpp"
#import "handGesture.hpp"
#import "myImage.hpp"
// algorithm

#import "ImageProcess.h"

@interface FirstViewController ()

@property (nonatomic, retain) UIImageView *imageView;

@property (nonatomic, retain) LabelSlider *labelSlider;

@end

@implementation FirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    self.imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.imageView];
    UIImage *image = [UIImage imageNamed:@"IMG_0835.JPG"];
    self.imageView.image = image;
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
    
    LabelSlider *labelSlider = [[LabelSlider alloc] initWithFrame:CGRectMake(0, 25, self.view.bounds.size.width, 20)];
    [labelSlider.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventTouchUpInside];
    [labelSlider.slider addTarget:self action:@selector(onValueChanged:) forControlEvents:UIControlEventTouchUpOutside];
//    [labelSlider.slider modifyStyle];
    labelSlider.label.text = nil;
    labelSlider.slider.minimumValue = 2.0f;
    labelSlider.slider.maximumValue = 100.0f;
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

#pragma mark -
#pragma mark Utility
// NOTE you SHOULD cvReleaseImage() for the return value when end of the code.
- (IplImage *)createIplImageFromUIImage:(UIImage *)image {
    // Getting CGImage from UIImage
    CGImageRef imageRef = image.CGImage;
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Creating temporal IplImage for drawing
    IplImage *iplimage = cvCreateImage(cvSize(image.size.width,image.size.height), IPL_DEPTH_8U, 4);
    
    // Creating CGContext for temporal IplImage
    CGContextRef contextRef = CGBitmapContextCreate(iplimage->imageData, iplimage->width, iplimage->height, iplimage->depth, iplimage->widthStep, colorSpace, kCGImageAlphaPremultipliedLast|kCGBitmapByteOrderDefault);
    
    // Drawing CGImage to CGContext
    CGContextDrawImage(contextRef, CGRectMake(0, 0, image.size.width, image.size.height), imageRef);
    CGContextRelease(contextRef);
    CGColorSpaceRelease(colorSpace);
    
    // Creating result IplImage
    IplImage *ret = cvCreateImage(cvGetSize(iplimage), IPL_DEPTH_8U, 3);
    cvCvtColor(iplimage, ret, CV_RGBA2BGR);
    cvReleaseImage(&iplimage);
    
    return ret;
}


// NOTE You should convert color mode as RGB before passing to this function
- (UIImage *)UIImageFromIplImage:(IplImage *)image {
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    // Allocating the buffer for CGImage
    NSData *data =
    [NSData dataWithBytes:image->imageData length:image->imageSize];
    CGDataProviderRef provider =
    CGDataProviderCreateWithCFData((CFDataRef)data);
    // Creating CGImage from chunk of IplImage
    CGImageRef imageRef = CGImageCreate(
                                        image->width, image->height,
                                        image->depth, image->depth * image->nChannels, image->widthStep,
                                        colorSpace, kCGImageAlphaNone|kCGBitmapByteOrderDefault,
                                        provider, NULL, false, kCGRenderingIntentDefault
                                        );
    // Getting UIImage from CGImage
    UIImage *ret = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    return ret;
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

- (void)showImageAtIndex:(NSInteger)j {
    self.title = [NSString stringWithFormat:@"%zd", j];
//    [self wmcSetNavigationBarTitleStyle];
    
    UIImage *image = nil;
    
    NSString *fileName = [NSString stringWithFormat:@"MYIMG_ORI%zd.JPG", j];
//    NSString *fileName = [NSString stringWithFormat:@"MYIMG_SMALL%zd.JPG", j];
    NSLog(@"current filename=%@", fileName);
    
    image = [UIImage imageNamed:fileName];
    if (!image)
        return;
    //    CGSize newSize = CGSizeMake(image.size.width / 4.0, image.size.height / 4.0);
    //    image = [image resizeImageContext:nil size:newSize];
    image = [ImageProcess correctImage:image];
    IplImage *ipImage = [self createIplImageFromUIImage:image];
    
    NSLog(@"width=%d, height=%d", ipImage->width, ipImage->height);
    HandGesture hg;
    MyImage * myImage = detectHand(ipImage, hg);
    NSLog(@"width=%d, height=%d", myImage->src.cols, myImage->src.rows);
    IplImage qImg;
    qImg = IplImage(myImage->src);
    
    IplImage *ret1 = cvCreateImage(cvGetSize(&qImg), IPL_DEPTH_8U, 3);
    cvCvtColor(&qImg, ret1, CV_BGR2RGB);
    self.imageView.image = [self UIImageFromIplImage:ret1];
    delete myImage;
    cvReleaseImage(&ipImage);
    cvReleaseImage(&ret1);
}

@end
