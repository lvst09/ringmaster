//
//  StrokeView.h
//  CapsJoinsView
//
//  Created by mion on 13-5-27.
//  Copyright (c) 2013年 mion. All rights reserved.
//  实现渐变涂抹，可以设置CAP和JOIN，自动判断叠加还是path绘制
//  

#import "StrokeView.h"

@interface StrokeView2Brush : StrokeView
{
}
#if USE_STROKE_BMP
-(void) addPath:(CGPoint)from and:(CGPoint)to;
#else
-(void) setStrokeColorAccordingDrawType:(DrawType)dt;
#endif
@end
