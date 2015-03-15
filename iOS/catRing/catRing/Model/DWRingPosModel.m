//
//  DWRingPosModel.m
//  catRing
//
//  Created by sky on 15/3/8.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "DWRingPosModel.h"

@implementation DWRingPosModel

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeFloat:self.rotationAngleX forKey:@"rotationAngleX"];
    [aCoder encodeFloat:self.rotationAngleY forKey:@"rotationAngleY"];
    [aCoder encodeFloat:self.rotationAngleZ forKey:@"rotationAngleZ"];
    [aCoder encodeFloat:self.ringAngle forKey:@"ringAngle"];
    [aCoder encodeFloat:self.ringCenterX forKey:@"ringCenterX"];
    [aCoder encodeFloat:self.ringCenterY forKey:@"ringCenterY"];
    [aCoder encodeFloat:self.ringWidth forKey:@"ringWidth"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super init]) {
        self.rotationAngleX = [aDecoder decodeFloatForKey:@"rotationAngleX"];
        self.rotationAngleY = [aDecoder decodeFloatForKey:@"rotationAngleY"];
        self.rotationAngleZ = [aDecoder decodeFloatForKey:@"rotationAngleZ"];
        self.ringAngle = [aDecoder decodeFloatForKey:@"ringAngle"];
        self.ringCenterX = [aDecoder decodeFloatForKey:@"ringCenterX"];
        self.ringCenterY = [aDecoder decodeFloatForKey:@"ringCenterY"];
        self.ringWidth = [aDecoder decodeFloatForKey:@"ringWidth"];
    }
    return self;
}

@end
