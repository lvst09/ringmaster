//
//  DWHandColorPointView.m
//  catRing
//
//  Created by sky on 15/3/21.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "DWHandColorPointView.h"

@implementation DWHandColorPointView

- (void)addViewAtPoint:(CGPoint)point {
    UIView *view1 = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 6, 6)];
    view1.layer.borderWidth = 2.f;
    view1.layer.borderColor = [UIColor greenColor].CGColor;
    view1.center = point;
    [self addSubview:view1];
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self addViewAtPoint:CGPointMake(119, 196)];
        [self addViewAtPoint:CGPointMake(171, 201)];
        [self addViewAtPoint:CGPointMake(206, 218)];
        [self addViewAtPoint:CGPointMake(247, 245)];
        [self addViewAtPoint:CGPointMake(54, 321)];
        [self addViewAtPoint:CGPointMake(133, 362)];
        [self addViewAtPoint:CGPointMake(197, 362)];
//        pushIntoROI(roi, 510, 141, square_len, m->src);
//        pushIntoROI(roi, 741, 205, square_len, m->src);
//        pushIntoROI(roi, 422, 210, square_len, m->src);
//        pushIntoROI(roi, 324, 284, square_len, m->src);
//        pushIntoROI(roi, 421, 370, square_len, m->src);
//        pushIntoROI(roi, 625, 522, square_len, m->src);
//        pushIntoROI(roi, 823, 386, square_len, m->src);
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