//
//  DWRingPositionInfo.m
//  MyCocosRingTest1
//
//  Created by sky on 15/3/1.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "DWRingPositionInfo.h"
@import CoreGraphics;
@import UIKit;
@implementation DWRingPositionInfo

- (NSString *)description {
    return [NSString stringWithFormat:@"center:%@, min:%@, max:%@", [NSValue valueWithCGPoint:self.centerPoint], [NSValue valueWithCGPoint:self.minPoint], [NSValue valueWithCGPoint:self.maxPoint]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.centerPoint] forKey:@"centerPoint"];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.minPoint] forKey:@"minPoint"];
    [aCoder encodeObject:[NSValue valueWithCGPoint:self.maxPoint] forKey:@"maxPoint"];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    if( self = [super init])
    {
        self.centerPoint  = [[aDecoder decodeObjectForKey:@"centerPoint"] CGPointValue];
        self.minPoint  = [[aDecoder decodeObjectForKey:@"minPoint"] CGPointValue];
        self.maxPoint  = [[aDecoder decodeObjectForKey:@"maxPoint"] CGPointValue];
    }

    return self;
}

@end
