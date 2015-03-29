//
//  DWHandColorPointView.m
//  catRing
//
//  Created by sky on 15/3/21.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "DWHandColorPointView.h"
#import "CommonConfig.h"

@implementation DWHandColorPointView

- (void)addViewAtPoint:(CGPoint)point {
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
    view1.layer.borderWidth = 2.f;
    view1.layer.borderColor = [UIColor greenColor].CGColor;
    view1.center = CGPointMake(point.x * self.bounds.size.width, point.y * self.bounds.size.height);
    [self addSubview:view1];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        
        int len = sizeof(pointArrX) / sizeof(double);
        for (int i = 0; i < len; ++i) {
            [self addViewAtPoint:CGPointMake(pointArrX[i], pointArrY[i])];
        }
    }
    return self;
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
