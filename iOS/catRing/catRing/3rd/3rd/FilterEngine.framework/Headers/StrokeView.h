//
//  StrokeView.h
//  CapsJoinsView
//
//  Created by mion on 13-5-27.
//  Copyright (c) 2013年 mion. All rights reserved.
//  实现渐变涂抹，可以设置CAP和JOIN，自动判断叠加还是path绘制
//  

#import <UIKit/UIKit.h>
#include "type_common.h"
#define DISPLAY_MASK_VIEW 0
#define USE_STROKE_BMP 1
@protocol ManuFaceMaskWithROIDelegate;
typedef enum
{
    MaskPen,
    MaskPen2,
    MaskEraser
} DrawType;

#if USE_STROKE_BMP

int isInsideRect(int x, int y, MRect rc);
#endif
@interface StrokeView : NSObject
{
#if USE_STROKE_BMP
    Image _tmpl, _maskImage;
    MPoint _tmplLeftCenter, _tmplRightCenter;
    int _tmplBrushSize;
    CGPoint _from;
#else
#endif
}

@property(nonatomic, assign) CGLineCap cap;
@property(nonatomic, assign) CGLineJoin join;
@property(nonatomic, assign) CGFloat strokeWidth;
@property(nonatomic, assign) CGColorRef strokeColor;
@property(nonatomic, assign) CGFloat turnAngle; // 自动叠加阈值，角度，当涂抹线段夹角小于些角度认为是试图叠加
@property(assign, nonatomic) DrawType dt;
@property(assign) id<ManuFaceMaskWithROIDelegate> maskUser;
@property(nonatomic, assign) bool useGradient;

- (id)initWithMaskSize:(CGSize)maskSize;
-(void) setMaskDimension:(int)wid withHeight:(int)hgt;
//-(Image) getMask;

-(void)touchesBegan:(CGPoint)pt;//
// Handles the start of a touch
-(void)touchesMoved:(CGPoint)pt;//(NSSet *)touches withEvent:(UIEvent *)event;
// Handles the end of a touch event.
-(void)touchesEnded:(CGPoint)pt;//(NSSet *)touches withEvent:(UIEvent *)event;
@end
