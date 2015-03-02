//
//  DWRingPositionInfo.m
//  MyCocosRingTest1
//
//  Created by sky on 15/3/1.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "DWRingPositionInfo.h"

@implementation DWRingPositionInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"center:%@, min:%@, max:%@", [NSValue valueWithCGPoint:self.centerPoint], [NSValue valueWithCGPoint:self.minPoint], [NSValue valueWithCGPoint:self.maxPoint]];
}

@end
