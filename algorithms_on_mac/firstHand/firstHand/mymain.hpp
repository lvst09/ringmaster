#ifndef _MAIN_HEADER_
#define _MAIN_HEADER_

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>

class HandGesture;
class MyImage;

#define ORIGCOL2COL CV_BGR2HLS
#define COL2ORIGCOL CV_HLS2BGR
#define NSAMPLES 7
#define PI 3.14159

int mymain();

// #step 1
void findROIColorInPalm(IplImage *image);
// or this
void findROIColorInPalm(cv::Mat *image);

// #step 2
MyImage * detectHand(IplImage *inputImage,  HandGesture &hg);
MyImage * detectHand(cv::Mat *inputImage,  HandGesture &hg);

// private functions
void processOnImageWithShowImage(MyImage &m1, HandGesture &hg);

#define kUseCamera 0

#define __OBJC__ 1

#endif
