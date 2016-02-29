//
//  AxialTransfer.h
//  MRCamera
//
//  Created by Patrick Yang on 12-8-29.
//  Copyright (c) 2012年 Microrapid. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>

enum {
    AxialTransferBlurTypeNone = 0,
    AxialTransferBlurTypeCircle,
    AxialTransferBlurTypeStar,
    AxialTransferBlurTypeHeart,
};


@interface AxialTransfer : NSObject

@property (nonatomic, assign) int blurType;
@property (nonatomic, assign) float strength;

- (id)initWithImage:(UIImage *)image;
- (void)updateBlurImage;
- (void)setImage:(UIImage *)image;

- (UIImage *)blurRoundWithCenterX:(float)centerX andCenterY:(float)centerY andInnerRadius:(int)innerRadius andOuterRadius:(int)outerRadius;
- (UIImage *)blurParallelWithX:(float)x andY:(float)y andTheta:(float)theta andInnerRadius:(int)innerRadius andOuterRadius:(int)outerRadius;
- (UIImage *)blurEllipseWithA:(float)a andX:(float)x andY:(float)y andTheta:(float)theta andInnerRadius:(int)innerRadius andOuterRadius:(int)outerRadius;

@end
