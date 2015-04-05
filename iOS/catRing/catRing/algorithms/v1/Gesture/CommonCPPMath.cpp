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
