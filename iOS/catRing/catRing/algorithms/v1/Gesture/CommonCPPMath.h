//
//  CommonCPPMath.h
//  catRing
//
//  Created by sky on 15/4/3.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#ifndef __catRing__CommonCPPMath__
#define __catRing__CommonCPPMath__

#include <stdio.h>
#include "opencv2/imgproc/imgproc.hpp"
#include "opencv2/imgproc/types_c.h"
#include "opencv2/highgui/highgui_c.h"
#include <opencv2/opencv.hpp>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include "myImage.hpp"
#include "roi.hpp"
#include "handGesture.hpp"
#include <vector>
#include <cmath>
#include "mymain.hpp"
#include "CommonConfig.h"


//Point2i middlePoint(cv::Point_<int>, cv::Point_<int>);
Point2i middlePoint(Point2i p1, Point2i p2);

double distanceOfPoint(Point2i p1, Point2i p2);

double vectorCrossAngle(Point2i p1, Point2i p2);

Point2i vectorBetweenPoints(Point p1, Point p2);
#endif /* defined(__catRing__CommonCPPMath__) */
