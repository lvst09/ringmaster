//
//  test4.cpp
//  firstHand
//
//  Created by sky on 15/4/5.
//  Copyright (c) 2015年 NoName. All rights reserved.
//

#include "test4.h"

// test4
#include "opencv/cv.h"
#include "opencv2/highgui/highgui.hpp"
#include "opencv/cxcore.h"
#include <opencv2/legacy/legacy.hpp>
#include <iostream>
#include <stdio.h>
#include <math.h>
#include <string.h>

IplImage *image = 0 ; //原始图像
IplImage *image2 = 0 ; //原始图像copy

using namespace std;
int Thresholdness = 141;
int ialpha = 20;
int ibeta=20;
int igamma=20;

static IplImage * shrink(IplImage *input, double scale) {
    IplImage *desc = NULL;
    IplImage *src = input;
    CvSize sz;
    if(src)
    {
        sz.width = src->width*scale;
        sz.height = src->height*scale;
        desc = cvCreateImage(sz,src->depth,src->nChannels);
        cvResize(src,desc,CV_INTER_CUBIC);
    }
    return desc;
}

void onChange(int pos)
{

    if(image2) cvReleaseImage(&image2);
    if(image) cvReleaseImage(&image);

    image2 = cvLoadImage("/Users/sky/Desktop/gesture/firstHand2/firstHand/Resources/MYIMG_ORI0.JPG",1); //显示图片
    image= cvLoadImage("/Users/sky/Desktop/gesture/firstHand2/firstHand/Resources/MYIMG_ORI0.JPG",0);
    image2 = shrink(image2, 0.2);
    image = shrink(image, 0.2);
    cvThreshold(image,image,Thresholdness,255,CV_THRESH_BINARY); //分割域值

    CvMemStorage* storage = cvCreateMemStorage(0);
    CvSeq* contours = 0;

    cvFindContours( image, storage, &contours, sizeof(CvContour), //寻找初始化轮廓
                   CV_RETR_EXTERNAL , CV_CHAIN_APPROX_SIMPLE );

    if(!contours) return ;
    int length = contours->total;
//    if(length<10) return ;
    CvPoint* point = new CvPoint[length]; //分配轮廓点

    CvSeqReader reader;
    CvPoint pt= cvPoint(0,0);;
    CvSeq *contour2=contours;

    cvStartReadSeq(contour2, &reader);
    for (int i = 0; i < length; i++)
    {
        CV_READ_SEQ_ELEM(pt, reader);
        point[i]=pt;
    }
    cvReleaseMemStorage(&storage);

    //显示轮廓曲线
    for(int i=0;i<length;i++)
    {
        int j = (i+1)%length;
        cvLine( image2, point[i],point[j],CV_RGB( 0, 0, 255 ),1,8,0 );
    }

    float alpha=ialpha/100.0f;
    float beta=ibeta/100.0f;
    float gamma=igamma/100.0f;

    CvSize size;
    size.width=3;
    size.height=3;
    CvTermCriteria criteria;
    criteria.type=CV_TERMCRIT_ITER;
    criteria.max_iter=1000;
    criteria.epsilon=0.1;
//    cvSnakeImage( image, point,length,&alpha,&beta,&gamma,0,size,criteria,0 );

    //显示曲线
    for(int i=0;i<length;i++)
    {
        int j = (i+1)%length;
        cvLine( image2, point[i],point[j],CV_RGB( 0, 255, 0 ),1,8,0 );
    }
    delete []point;

}

int test4main()
{


    cvNamedWindow("win1",0);
    cvCreateTrackbar("Thd", "win1", &Thresholdness, 255, onChange);
    cvCreateTrackbar("alpha", "win1", &ialpha, 100, onChange);
    cvCreateTrackbar("beta", "win1", &ibeta, 100, onChange);
    cvCreateTrackbar("gamma", "win1", &igamma, 100, onChange);
    cvResizeWindow("win1",300,500);
    onChange(0);

    for(;;)
    {
        if(cvWaitKey(40)==27) break;
        cvShowImage("win1",image2);
    }

    return 0;
}