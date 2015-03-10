//
//  SelectPointViewController.m
//  DW
//
//  Created by sky on 15/3/6.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "SelectPointViewController.h"

@interface SelectPointViewController()

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIImageView * tempView;
@property (nonatomic, strong) UIButton *confirmButton;
//@property (nonatomic, strong) UIImage *inputImage;
@end

@implementation SelectPointViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    UIImage *image = [UIImage imageNamed:@"Default.png"];
    CGRect frame = self.view.bounds;
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 50, frame.size.width, 640.f/3.f)];
    imageView.image = self.inputImage;
//    imageView.contentMode = UIView
    [self.view addSubview:imageView];
    self.imageView = imageView;
    
    UIImageView * tempView = [[UIImageView alloc] initWithFrame:CGRectMake(150, 198, 35, 35)];
    tempView.userInteractionEnabled = YES;
    tempView.contentMode = UIViewContentModeCenter;
    tempView.image = [UIImage imageNamed:@"DW_Plus.png"];
    tempView.highlightedImage = [UIImage imageNamed:@"DW_PlusPressed.png"];
    [self.view addSubview:tempView];
    self.tempView = tempView;
    
    UIPanGestureRecognizer *locationLeftPan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanMoveLocation:)];
    locationLeftPan.minimumNumberOfTouches = 1;
    locationLeftPan.maximumNumberOfTouches = 1;
    [tempView addGestureRecognizer:locationLeftPan];
    
    UIButton *confirmButton = [UIButton buttonWithType:UIButtonTypeCustom];
    confirmButton.frame = CGRectMake(0, 0, 44, 44);
    [confirmButton setTitle:@"OK" forState:UIControlStateNormal];
    [confirmButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:confirmButton];
    [confirmButton addTarget:self action:@selector(onConfirmButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.confirmButton = confirmButton;
    
//    locationLeft = tempView;
}

- (void)onConfirmButtonPressed:(UIButton *)sender {
    if (self.navigationController) {
        [self.navigationController popViewControllerAnimated:YES];
    } else {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}


- (void)handlePanMoveLocation:(UIPanGestureRecognizer *)pan
{
    UIImageView * panView = nil, * otherView = nil;
    panView = self.tempView;
//    if (pan == locationLeftPan)
//    {
//        panView = locationLeft;
//        otherView = locationRight;
//    }
//    else if (pan == locationRightPan)
//    {
//        panView = locationRight;
//        otherView = locationLeft;
//    }
    
    if (panView)
    {
//        self.magnifierGlass.foregroundImage =  panView;
        CGPoint off = [pan translationInView:pan.view];
        CGPoint point = panView.center;
        point.x += off.x;
        point.y += off.y;
        panView.center = point;
        [pan setTranslation:CGPointZero inView:pan.view];
        
        CGPoint point1 = [self.imageView convertPoint:point fromView:self.view];
//        CGPoint point2 = [self.imageView convertPoint:otherView.center fromView:self.view];
        
//        CGPoint distancePt = CGPointMake(point1.x - point2.x, point1.y - point2.y);
//        distancePt = [contentView pointInImageCoordinate:distancePt];
//        float distance = sqrtf(distancePt.x * distancePt.x + distancePt.y * distancePt.y);
        // 设置一定像素的安全距离
//        float SafeDistance = 20.0f;
//        if (distance > SafeDistance)
//        {
//            panView.highlighted = NO;
//            
//            CGPoint pointOnScroll = [contentScrollView convertPoint:point fromView:panView.superview];
//            if (CGRectContainsPoint(contentScrollView.bounds, pointOnScroll)) {
//                panView.center = point;
//                [pan setTranslation:CGPointZero inView:pan.view];
//            }
//        }
//        panView.highlighted = (distance - 1  < SafeDistance);
        panView.highlighted = YES;
        UIGestureRecognizerState state = pan.state;
        if (state == UIGestureRecognizerStateBegan)
        {
            panView.alpha = 0.5f;
        }
        else if (state == UIGestureRecognizerStateEnded || state == UIGestureRecognizerStateFailed || state == UIGestureRecognizerStateCancelled)
        {
            panView.alpha = 1.0f;
            panView.highlighted = NO;
        }
    }
    
//    if (panView)
//    {
//        // 放大镜
//        UIGestureRecognizerState state = pan.state;
//        if (state == UIGestureRecognizerStateChanged)
//        {
//            CGPoint localPoint = [self.view convertPoint:panView.center fromView:panView.superview];
//            [self updateMagnifierWithPoint:localPoint zoomScale:contentScrollView.zoomScale];
//        }
//        else if (state == UIGestureRecognizerStateBegan)
//        {
//            CGPoint localPoint = [self.view convertPoint:panView.center fromView:panView.superview];
//            [self updateMagnifierWithPoint:localPoint zoomScale:contentScrollView.zoomScale];
//            [self delayShowMagniferGlass];
//        }
//        else if (state == UIGestureRecognizerStateEnded)
//        {
//            CGPoint localPoint = [self.view convertPoint:panView.center fromView:panView.superview];
//            [self updateMagnifierWithPoint:localPoint zoomScale:contentScrollView.zoomScale];
//            [self cancelShowMagniferGlass:YES];
//        }
//        else if (state == UIGestureRecognizerStateFailed || state == UIGestureRecognizerStateCancelled)
//        {
//            [self cancelShowMagniferGlass:NO];
//        }
//    }
    
    //    [self updateMagnifierWithPan:pan];
}



@end
