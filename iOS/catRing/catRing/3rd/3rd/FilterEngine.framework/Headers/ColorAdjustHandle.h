//
//  ColorAdjustHandle.h
//  FilterEngine
//
//  Created by patyang on 14/11/17.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColorAdjustHandle : NSObject

@property (nonatomic, assign) BOOL lowerPerformance;
@property (nonatomic, assign) CGFloat lightValue;
@property (nonatomic, assign) CGFloat brightValue;
@property (nonatomic, assign) CGFloat contrastValue;
@property (nonatomic, assign) CGFloat saturationValue;
@property (nonatomic, assign) CGFloat scaleCValue;
@property (nonatomic, assign) CGFloat scaleTValue;
@property (nonatomic, assign) CGFloat sharpenValue;

- (id)initWithUIImage:(UIImage *)image;
- (void)setUIImage:(UIImage *)image;
- (UIImage *)processImage;

@end
