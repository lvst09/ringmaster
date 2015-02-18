//
//  MathUtil.m
//  seagullHD
//
//  Created by mikedong on 11-6-27.
//  Copyright 2011年 tencent. All rights reserved.
//

#import "MathUtil.h"


#pragma mark -
#pragma mark 常用数学函数

double getDis(CGPoint pt)
{
    return sqrt((pt.x)*(pt.x) + (pt.y)*(pt.y));
}

double getAngle(CGPoint pt)
{
    double angle = atan2(pt.y, pt.x);
    return CHECK_ANGLE(angle);
}

double getAngleBetween(CGPoint pt1, CGPoint pt2)
{
    double angle1 = getAngle(pt1);
    angle1 = CHECK_ANGLE(angle1);
    double angle2 = getAngle(pt2);
    angle2 = CHECK_ANGLE(angle2);
    
    angle1 = angle2 - angle1;
    angle1 = CHECK_ANGLE(angle1);
    
    return angle1;
}

CGPoint transToPolar(CGPoint pt)
{
    return CGPointMake(getDis(pt), getAngle(pt));
}

CGPoint transFromPolar(CGPoint pt)
{
    return CGPointMake(pt.x * cos(pt.y), pt.x * sin(pt.y));
}

CGPoint pointSub(CGPoint pt1, CGPoint pt2)
{
    return CGPointMake(pt1.x - pt2.x, pt1.y - pt2.y);
}

CGPoint pointAdd(CGPoint pt1, CGPoint pt2)
{
    return CGPointMake(pt1.x + pt2.x, pt1.y + pt2.y);
}

CGPoint pointMulti(CGPoint pt1, double factor)
{
    return CGPointMake(pt1.x * factor, pt1.y * factor);
}

CGPoint pointDivide(CGPoint pt1, double factor)
{
    return pointMulti(pt1, 1 / factor);
}

CGPoint pointNormalize(CGPoint pt)
{
    if (getDis(pt) > 0.001)
    {
        return pointDivide(pt, getDis(pt));
    }
    else
    {
        return pt;
    }
}

double mix(double x, double y, double alpha)
{
    return x * alpha + y * (1 - alpha);
}

double smoothstep(double edge1, double edge2, double alpha)
{
    if (edge2 < (edge1 + 0.00001))
        return 1.0;
    
    if (alpha <= edge1)
    {
        return 0.0;
    }
    else if (alpha >= edge2)
    {
        return 1.0;
    }
    else 
    {
        alpha = (alpha - edge1)/ (edge2 - edge1);
        if (alpha < 0.0) alpha = 0.0;
        if (alpha > 1.0) alpha = 1.0;
        return alpha * alpha * (3 - 2 * alpha);
    }
}

// 获取矩形中心
CGPoint getRectCenter(CGRect rect)
{
    return CGPointMake(rect.origin.x + rect.size.width / 2, 
                       rect.origin.y + rect.size.height / 2);
}

// 获取能够容纳在innerRect中的矩形
CGRect getInnerRect(CGSize size, CGRect innerRect)
{
    if (size.height == 0 || size.width ==0 || 
        innerRect.size.width == 0 || innerRect.size.height == 0)
        return innerRect;
    
    double imageScale = size.width / size.height;
    double rectScale = innerRect.size.width / innerRect.size.height;
    
    if (imageScale > rectScale)
    {
        double scale = innerRect.size.width / size.width;
        double newHeight = size.height * scale;
        return CGRectMake(roundf(innerRect.origin.x), roundf(innerRect.origin.y + (innerRect.size.height - newHeight) / 2), 
                          roundf(innerRect.size.width), roundf(newHeight));
    }
    else
    {
        double scale = innerRect.size.height / size.height;
        double newWidth = size.width * scale;
        return CGRectMake(roundf(innerRect.origin.x + (innerRect.size.width - newWidth) / 2), roundf(innerRect.origin.y), 
                          roundf(newWidth), roundf(innerRect.size.height));
    }
}

// 获取能够容纳image的矩形
CGRect getOuterRect(CGSize size, CGRect outerRect)
{
    if (size.height == 0 || size.width ==0 || 
        outerRect.size.width == 0 || outerRect.size.height == 0)
        return outerRect;
    
    double imageScale = size.width / size.height;
    double rectScale = outerRect.size.width / outerRect.size.height;
    
    if (imageScale > rectScale)
    {
        double scale = outerRect.size.height / size.height;
        double newWidth = size.width * scale;
        return CGRectMake(roundf(outerRect.origin.x + (outerRect.size.width - newWidth) / 2), roundf(outerRect.origin.y), 
                          roundf(newWidth), roundf(outerRect.size.height));
    }
    else
    {
        double scale = outerRect.size.width / size.width;
        double newHeight = size.height * scale;
        return CGRectMake(roundf(outerRect.origin.x), roundf(outerRect.origin.y + (outerRect.size.height - newHeight) / 2), 
                          roundf(outerRect.size.width), roundf(newHeight));
    }
}

CGRect getFitRect(CGSize srcSize, CGSize resultSize, CGRect faceRect)
{
    if (srcSize.width < 0.001 || srcSize.height < 0.001 ||
        resultSize.width < 0.001 || resultSize.height < 0.001)
    {
        return CGRectMake(0, 0, srcSize.width, srcSize.height);
    }
    
    double srcScale = srcSize.width / srcSize.height;
    double resultScale = resultSize.width / resultSize.height;
    
    if (faceRect.size.width > 0.001)
    {
        CGPoint faceCenter = CGPointMake(faceRect.origin.x + faceRect.size.width / 2, 
                                         faceRect.origin.y + faceRect.size.height / 2);
        if (srcScale > resultScale)
        {
            CGFloat newWidth = resultScale * srcSize.height;
            int newX = round(faceCenter.x - newWidth / 2);
            if ((newX + newWidth) > srcSize.width)
            {
                newX = srcSize.width - newWidth;
            }
            if (newX < 0)
            {
                newX = 0;
            }
            return CGRectMake(newX, 0, round(newWidth), srcSize.height);
        }
        else
        {
            CGFloat newHeight = srcSize.width / resultScale;
            int newY = round((srcSize.height - newHeight) / 2);
            if ((newY + newHeight) > srcSize.height)
            {
                newY = srcSize.height - newHeight;
            }
            if (newY < 0)
            {
                newY = 0;
            }
            return CGRectMake(0, newY, srcSize.width, round(newHeight));
        }
    }
    else
    {
        if (srcScale > resultScale)
        {
            CGFloat newWidth = resultScale * srcSize.height;
            int newX = round((srcSize.width - newWidth) / 2);
            return CGRectMake(newX, 0, round(newWidth), srcSize.height);
        }
        else
        {
            CGFloat newHeight = srcSize.width / resultScale;
            int newY = round((srcSize.height - newHeight) / 2);
            return CGRectMake(0, newY, srcSize.width, round(newHeight));
        }
    }
    
    return CGRectZero;
}

// 以某点为原点对矩形进行缩放
CGRect scaleRectWithAnchor(CGRect rect , CGPoint center, double scale)
{
    CGPoint origin = rect.origin;
    CGPoint offset = pointSub(origin, center);
    offset = pointMulti(offset, scale);
    origin = pointAdd(offset, center);
    
    return CGRectMake(origin.x, origin.y, rect.size.width * scale, rect.size.height * scale);
}


CGPoint transPosFromRect(CGPoint pos, CGRect srcRect, CGRect dstRect)
{
    if (srcRect.size.width < EPSILON
        || srcRect.size.height < EPSILON
        )
    {
        return pos;
    }
    
    CGPoint offset = pointSub(pos, srcRect.origin);
    double xScale = dstRect.size.width / srcRect.size.width;
    double yScale = dstRect.size.height / srcRect.size.height;
    offset.x *= xScale;
    offset.y *= yScale;
    
    return pointAdd(offset, dstRect.origin);
}

NSMutableArray * randomSequence(int n)
{
    NSMutableArray * result = [[NSMutableArray alloc] init];
    
    NSMutableArray * source = [[NSMutableArray alloc] init];
    for (NSInteger i = 1; i <= n; i++)
    {
        [source addObject:[NSNumber numberWithInt:(int)i]];
    }
    
    do
    {
        int i = random() % n;
        [result addObject:[source objectAtIndex:i]];
        [source removeObjectAtIndex:i];
        n--;
    } while (n > 0);
    
    return result;
}
