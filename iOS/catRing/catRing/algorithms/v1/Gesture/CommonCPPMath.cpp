//
//  CommonCPPMath.cpp
//  catRing
//
//  Created by sky on 15/4/3.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#include "CommonCPPMath.h"

Point2i middlePoint(Point2i p1, Point2i p2)
{
    return Point((p1.x+p2.x)/2, (p1.y+p2.y)/2 );
}
double distanceOfPoint(Point2i p1, Point2i p2)
{
    return  sqrt((pow((p1.x - p2.x),2) +  pow((p1.y - p2.y),2)));
}

double vectorCrossAngle(Point p1, Point p2)
{
    double dotProduct =  ( p1.x * p2.x + p1.y * p2.y );
    
    double m = sqrt(p1.x*p1.x + p1.y*p1.y) * sqrt(p2.x*p2.x + p2.y*p2.y);
    
    return acos(dotProduct/m);
}

Point vectorBetweenPoints(Point p1, Point p2)
{
    return Point((p1.x - p2.x) ,(p1.y - p2.y));
}
