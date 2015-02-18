//
//  MathUtil.h
//  seagullHD
//
//  Created by mikedong on 11-6-27.
//  Copyright 2011年 tencent. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#ifdef __cplusplus
extern "C"
{
#endif

#pragma mark -
#pragma mark 常用数学函数

#define CHECK_ANGLE(angle) ((angle < 0) ? (2 * M_PI + angle) : ((angle > M_PI * 2) ? (angle - 2 * M_PI) : angle))
#define EPSILON 0.000000000001

double getDis(CGPoint pt);

double getAngle(CGPoint pt);

double getAngleBetween(CGPoint pt1, CGPoint pt2);

CGPoint transToPolar(CGPoint pt);

CGPoint transFromPolar(CGPoint pt);

CGPoint pointSub(CGPoint pt1, CGPoint pt2);

CGPoint pointAdd(CGPoint pt1, CGPoint pt2);

CGPoint pointMulti(CGPoint pt1, double factor);

CGPoint pointDivide(CGPoint pt1, double factor);

CGPoint pointNormalize(CGPoint pt);
    
double mix(double x, double y, double alpha);
    
double smoothstep(double edge1, double edge2, double alpha);

// 获取矩形中心
CGPoint getRectCenter(CGRect rect);

// 获取能够容纳在innerRect中的矩形
CGRect getInnerRect(CGSize size, CGRect innerRect);

// 获取能够容纳image的矩形
CGRect getOuterRect(CGSize size, CGRect outerRect);

// 获取能够容纳image的矩形
CGRect getFitRect(CGSize srcSize, CGSize resultSize, CGRect faceRect);

// 以某点为原点对矩形进行缩放
CGRect scaleRectWithAnchor(CGRect rect , CGPoint center, double scale);

CGPoint transPosFromRect(CGPoint pos, CGRect srcRect, CGRect dstRect);

NSMutableArray * randomSequence(int n);
    
#ifdef __cplusplus
}
#endif
