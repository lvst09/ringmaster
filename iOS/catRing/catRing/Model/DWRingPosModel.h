//
//  DWRingPosModel.h
//  catRing
//
//  Created by sky on 15/3/8.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>

@interface DWRingPosModel : NSObject<NSCoding>

@property (nonatomic, assign) CGFloat rotationAngleX;
@property (nonatomic, assign) CGFloat rotationAngleY;
@property (nonatomic, assign) CGFloat rotationAngleZ;
@property (nonatomic, assign) CGFloat ringAngle;
@property (nonatomic, assign) CGFloat ringCenterX;
@property (nonatomic, assign) CGFloat ringCenterY;
@property (nonatomic, assign) CGFloat ringWidth;
@end
