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
#include "CommonCPPMath.h"
#include "PreHeader.h"

using namespace cv;
using namespace std;


/* Global Variables  */
//int fontFace = FONT_HERSHEY_PLAIN;
//int square_len;
int avgColor[NSAMPLES][3] ;
int c_lower[NSAMPLES][3];
int c_upper[NSAMPLES][3];
static vector <Point2i>  * firstFinger;
static vector <double>  * firstFeatureAngles;
static vector <Point2i> * firstFingerTipFeatures;
static vector <double> * firstFingerCrossAngles;

static int diff1 = 30;

//int avgBGR[3];
//int nrOfDefects;
//int iSinceKFInit;
//struct dim{int w; int h;}boundingDim;

//Mat edges;
//My_ROI roi1, roi2,roi3,roi4,roi5,roi6;
//vector <My_ROI> roi;
//vector <KalmanFilter> kf;
//vector <Mat_<float> > measurement;

/* end global variables */

//void init(MyImage *m){
//	square_len=20;
//	iSinceKFInit=0;
//}

void average(MyImage *m, vector<My_ROI> &roi);
void pushIntoROI(vector<My_ROI> &roi, int x, int y, int square_len, Mat &src);
void waitForPalmCover(MyImage* m);



// change a color from one space to another
void col2origCol(int hsv[3], int bgr[3], Mat src){
    Mat avgBGRMat=src.clone();
    for(int i=0;i<3;i++){
        avgBGRMat.data[i]=hsv[i];
    }
    cvtColor(avgBGRMat,avgBGRMat,COL2ORIGCOL);
    for(int i=0;i<3;i++){
        bgr[i]=avgBGRMat.data[i];
    }
}

// done
void printText(Mat src, string text){
#ifndef __OBJC__
    int fontFace1 = FONT_HERSHEY_PLAIN;
    putText(src,text,Point(src.cols/2, src.rows/10),fontFace1, 1.2f,Scalar(200,0,0),2);
#endif
}

void pushIntoROI(vector<My_ROI> &roi, int x, int y, int square_len, Mat &src) {
    roi.push_back(My_ROI(Point(x, y),Point(x+square_len, y+square_len), src));
}

void findROIColorInPalm(IplImage *image) {
    MyImage m(image);
    waitForPalmCover(&m);
}

void findROIColorInPalm(Mat *image) {
    MyImage m(image);
    waitForPalmCover(&m);
}

//(375,667)->(1280,720)
Point2i changePoint(double x, double y)
{
#if kUseLowResolution
    return Point2i(kLowResolutionLongSize - y * kLowResolutionLongSize, kLowResolutionShortSize - x * kLowResolutionShortSize);
//    return Point2i(568 - y * 568, 320 - x * 320);
#else
    return Point2i(1280 - y * 1280,720 - x * 720 );
#endif
}

void waitForPalmCover(MyImage* m){
    vector<My_ROI> roi;
    if (kUseCamera)
        m->cap >> m->src;
//    flip(m->src,m->src,1);
    int square_len = 20;
    
    dprintf("rows=%d, cols=%d", m->src.rows, m->src.cols);
    // rows=489, cols=652
    

    
#if 0
    // 原来默认的roi点的位置
    pushIntoROI(roi, m->src.cols/3, m->src.rows/6, square_len, m->src);
    pushIntoROI(roi, m->src.cols/4, m->src.rows/2, square_len, m->src);
    pushIntoROI(roi, m->src.cols/3, m->src.rows/1.5, square_len, m->src);
    pushIntoROI(roi, m->src.cols/2.5, m->src.rows/2.5, square_len, m->src);
    pushIntoROI(roi, m->src.cols/2, m->src.rows/1.5, square_len, m->src);
    pushIntoROI(roi, m->src.cols/2.5, m->src.rows/1.8, square_len, m->src);
    pushIntoROI(roi, m->src.cols/2, m->src.rows/2, square_len, m->src);
#else
    // 新的roi点的位置
    //    pushIntoROI(roi, 108, 121, square_len, m->src);
    //    pushIntoROI(roi, 326, 71, square_len, m->src);
    //    pushIntoROI(roi, 397, 157, square_len, m->src);
    //    pushIntoROI(roi, 245, 227, square_len, m->src);
    //    pushIntoROI(roi, 450, 330, square_len, m->src);
    //    pushIntoROI(roi, 186, 346, square_len, m->src);
    //    pushIntoROI(roi, 46, 233, square_len, m->src);
    
//    [self addViewAtPoint:CGPointMake(119, 196)];
//    [self addViewAtPoint:CGPointMake(171, 201)];
//    [self addViewAtPoint:CGPointMake(206, 218)];
//    [self addViewAtPoint:CGPointMake(247, 245)];
//    [self addViewAtPoint:CGPointMake(54, 321)];
//    [self addViewAtPoint:CGPointMake(133, 362)];
//    [self addViewAtPoint:CGPointMake(197, 362)];

//    Point2i point = changePoint(1, 1);
//    pushIntoROI(roi, point.x, point.y, square_len, m->src);
    
//    [self addViewAtPoint:CGPointMake(50, 100)];
//    [self addViewAtPoint:CGPointMake(50, 200)];
//    [self addViewAtPoint:CGPointMake(100, 100)];
    
//    [self addViewAtPoint:CGPointMake(119, 196)];
//    [self addViewAtPoint:CGPointMake(171, 201)];
//    [self addViewAtPoint:CGPointMake(206, 218)];
//    [self addViewAtPoint:CGPointMake(247, 245)];
//    [self addViewAtPoint:CGPointMake(54, 321)];
//    [self addViewAtPoint:CGPointMake(133, 362)];
//    [self addViewAtPoint:CGPointMake(197, 362)];
    
//    int pointArrX[] = {119, 171, 206, 247, 54, 133, 197};
//    int pointArrY[] = {196, 201, 218, 245, 321, 362, 362};
    
    long len = sizeof(pointArrX) / sizeof(double);
    for (int i = 0; i < len; ++i) {
        Point2i point = changePoint(pointArrX[i], pointArrY[i]);
        pushIntoROI(roi, point.x, point.y, square_len, m->src);
    }
//    {
//        
//        Point2i point = changePoint(119, 196);
//        pushIntoROI(roi, point.x, point.y, square_len, m->src);
//        
//        point = changePoint(171, 201);
//        pushIntoROI(roi, point.x, point.y, square_len, m->src);
//        
//        point = changePoint(206, 218);
//        pushIntoROI(roi, point.x, point.y, square_len, m->src);
//        
//        point = changePoint(247, 245);
//        pushIntoROI(roi, point.x, point.y, square_len, m->src);
//        //
//        point = changePoint(54, 321);
//        pushIntoROI(roi, point.x, point.y, square_len, m->src);
//        
//        point = changePoint(133, 362);
//        pushIntoROI(roi, point.x, point.y, square_len, m->src);
//        
//        point = changePoint(197, 362);
//        pushIntoROI(roi, point.x, point.y, square_len, m->src);
//        
//
//    }
    
    
//    Point2i point = changePoint(119, 196);
//    pushIntoROI(roi, point.x, point.y, square_len, m->src);
//    
//    point = changePoint(171, 201);
//    pushIntoROI(roi, point.x, point.y, square_len, m->src);
//
//    point = changePoint(206, 218);
//    pushIntoROI(roi, point.x, point.y, square_len, m->src);
//
//    point = changePoint(247, 245);
//    pushIntoROI(roi, point.x, point.y, square_len, m->src);
////
//    point = changePoint(54, 321);
//    pushIntoROI(roi, point.x, point.y, square_len, m->src);
//
//    point = changePoint(133, 362);
//    pushIntoROI(roi, point.x, point.y, square_len, m->src);
//
//    point = changePoint(197, 362);
//    pushIntoROI(roi, point.x, point.y, square_len, m->src);

//    pushIntoROI(roi, 364, 115, square_len, m->src);
//    pushIntoROI(roi, 369, 207, square_len, m->src);
//    pushIntoROI(roi, 422, 289, square_len, m->src);
//    pushIntoROI(roi, 347, 377, square_len, m->src);
//    pushIntoROI(roi, 122, 497, square_len, m->src);
//    pushIntoROI(roi, 154, 169, square_len, m->src);
//    pushIntoROI(roi, 78, 430, square_len, m->src);

#endif
    
//    roi.push_back(My_ROI(Point(m->src.cols/3, m->src.rows/6),Point(m->src.cols/3+square_len,m->src.rows/6+square_len),m->src));
//    roi.push_back(My_ROI(Point(m->src.cols/4, m->src.rows/2),Point(m->src.cols/4+square_len,m->src.rows/2+square_len),m->src));
//    roi.push_back(My_ROI(Point(m->src.cols/3, m->src.rows/1.5),Point(m->src.cols/3+square_len,m->src.rows/1.5+square_len),m->src));
//    roi.push_back(My_ROI(Point(m->src.cols/2.5, m->src.rows/2.5),Point(m->src.cols/2.5+square_len,m->src.rows/2.5+square_len),m->src));
//    roi.push_back(My_ROI(Point(m->src.cols/2, m->src.rows/1.5),Point(m->src.cols/2+square_len,m->src.rows/1.5+square_len),m->src));
//    roi.push_back(My_ROI(Point(m->src.cols/2.5, m->src.rows/1.8),Point(m->src.cols/2.5+square_len,m->src.rows/1.8+square_len),m->src));
//    roi.push_back(My_ROI(Point(m->src.cols/2, m->src.rows/2),Point(m->src.cols/2+square_len,m->src.rows/2+square_len),m->src));
    
    
    int times = 1;
    if (kUseCamera) {
        times = 50;
    }
    for(int i =0;i<times;i++){
        if (kUseCamera) {
            m->cap >> m->src;
            flip(m->src,m->src,1);
        }
        for(int j=0;j<NSAMPLES;j++){
            roi[j].draw_rectangle(m->src);
        }
        string imgText=string("Cover rectangles with palm");
        printText(m->src,imgText);
        
        if(i==30){
            //	imwrite("./images/waitforpalm1.jpg",m->src);
        }
#ifndef __OBJC__
        imshow("img1", m->src);

//        out << m->src;
        if(cv::waitKey(30) >= 0) break;
#endif
    }
    average(m, roi);
}

// todo
int getMedian(vector<int> val){
    int median;
    size_t size = val.size();
//#warning 可以优化，取中位数
    sort(val.begin(), val.end());
    if (size  % 2 == 0)  {
        median = val[size / 2 - 1] ;
    } else{
        median = val[size / 2];
    }
    return median;
}

// done
void getAvgColor(/*MyImage *m,*/My_ROI inputroi,int avg[3]){
    Mat r;
    inputroi.roi_ptr.copyTo(r);
    vector<int>hm;
    vector<int>sm;
    vector<int>lm;
    // generate vectors
    for(int i=2; i<r.rows-2; i++){
        for(int j=2; j<r.cols-2; j++){
            hm.push_back(r.data[r.channels()*(r.cols*i + j) + 0]) ;
            sm.push_back(r.data[r.channels()*(r.cols*i + j) + 1]) ;
            lm.push_back(r.data[r.channels()*(r.cols*i + j) + 2]) ;
        }
    }
    avg[0]=getMedian(hm);
    avg[1]=getMedian(sm);
    avg[2]=getMedian(lm);
}

void average(MyImage *m, vector<My_ROI> &roi) {
    if (kUseCamera)
    m->cap >> m->src;
//    flip(m->src,m->src,1);
    int times = 1;
    if (kUseCamera)
        times =30;
    for(int i=0;i<times;i++){
        if (kUseCamera) {
            m->cap >> m->src;
            flip(m->src,m->src,1);
        }
        cvtColor(m->src,m->src,ORIGCOL2COL);
        for(int j=0;j<NSAMPLES;j++){
            getAvgColor(/*m,*/roi[j],avgColor[j]);
            roi[j].draw_rectangle(m->src);
        }
        cvtColor(m->src,m->src,COL2ORIGCOL);
        string imgText=string("Finding average color of hand");
        printText(m->src,imgText);
#ifndef __OBJC__
        imshow("img1", m->src);
        if(cv::waitKey(30) >= 0) break;
#endif
    }
}

void initTrackbars(){
    for(int i=0;i<NSAMPLES;i++){
        c_lower[i][0]=12;
        c_upper[i][0]=7;
        c_lower[i][1]=30;
        c_upper[i][1]=40;
        c_lower[i][2]=80;
        c_upper[i][2]=80;
    }
#ifndef __OBJC__
    createTrackbar("lower1","trackbars",&c_lower[0][0],255);
    createTrackbar("lower2","trackbars",&c_lower[0][1],255);
    createTrackbar("lower3","trackbars",&c_lower[0][2],255);
    createTrackbar("upper1","trackbars",&c_upper[0][0],255);
    createTrackbar("upper2","trackbars",&c_upper[0][1],255);
    createTrackbar("upper3","trackbars",&c_upper[0][2],255);
#endif
}


void normalizeColors(/*MyImage * myImage*/){
    // copy all boundries read from trackbar
    // to all of the different boundries
    for(int i=1;i<NSAMPLES;i++){
        for(int j=0;j<3;j++){
            c_lower[i][j]=c_lower[0][j];
            c_upper[i][j]=c_upper[0][j];
        }
    }
    // normalize all boundries so that
    // threshold is whithin 0-255
    for(int i=0;i<NSAMPLES;i++){
        if((avgColor[i][0]-c_lower[i][0]) <0){
            c_lower[i][0] = avgColor[i][0] ;
        }if((avgColor[i][1]-c_lower[i][1]) <0){
            c_lower[i][1] = avgColor[i][1] ;
        }if((avgColor[i][2]-c_lower[i][2]) <0){
            c_lower[i][2] = avgColor[i][2] ;
        }if((avgColor[i][0]+c_upper[i][0]) >255){
            c_upper[i][0] = 255-avgColor[i][0] ;
        }if((avgColor[i][1]+c_upper[i][1]) >255){
            c_upper[i][1] = 255-avgColor[i][1] ;
        }if((avgColor[i][2]+c_upper[i][2]) >255){
            c_upper[i][2] = 255-avgColor[i][2] ;
        }
    }
}

/** @函数 main */
int myhist3(Mat input)
{
    //    Mat src, dst;
    //
    //    /// 装载图像
    //    src = imread( argv[1], 1 );
    
    if( !input.data )
    { return -1; }
    
    /// 分割成3个单通道图像 ( R, G 和 B )
    vector<Mat> rgb_planes;
    split( input, rgb_planes );
    
    /// 设定bin数目
    int histSize = 255;
    
    /// 设定取值范围 ( R,G,B) )
    float range[] = { 0, 255 } ;
    const float* histRange = { range };
    
    bool uniform = true; bool accumulate = false;
    
    Mat r_hist, g_hist, b_hist;
    
    /// 计算直方图:
    calcHist( &rgb_planes[0], 1, 0, Mat(), r_hist, 1, &histSize, &histRange, uniform, accumulate );
    calcHist( &rgb_planes[1], 1, 0, Mat(), g_hist, 1, &histSize, &histRange, uniform, accumulate );
    calcHist( &rgb_planes[2], 1, 0, Mat(), b_hist, 1, &histSize, &histRange, uniform, accumulate );
    
    // 创建直方图画布
    int hist_w = 400; int hist_h = 400;
    int bin_w = cvRound( (double) hist_w/histSize );
    
    Mat histImage( hist_w, hist_h, CV_8UC3, Scalar( 0,0,0) );
    
    /// 将直方图归一化到范围 [ 0, histImage.rows ]
    normalize(r_hist, r_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    normalize(g_hist, g_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    normalize(b_hist, b_hist, 0, histImage.rows, NORM_MINMAX, -1, Mat() );
    
    /// 在直方图画布上画出直方图
    for( int i = 1; i < histSize; i++ )
    {
        line( histImage, Point( bin_w*(i-1), hist_h - cvRound(r_hist.at<float>(i-1)) ) ,
             Point( bin_w*(i), hist_h - cvRound(r_hist.at<float>(i)) ),
             Scalar( 0, 0, 255), 2, 8, 0  );
//        cout << "i=" << i << ":" << g_hist.at<float>(i) << endl;
        cout << b_hist.at<float>(i) << endl;
        
        line( histImage, Point( bin_w*(i-1), hist_h - cvRound(g_hist.at<float>(i-1)) ) ,
             Point( bin_w*(i), hist_h - cvRound(g_hist.at<float>(i)) ),
             Scalar( 0, 255, 0), 2, 8, 0  );
        line( histImage, Point( bin_w*(i-1), hist_h - cvRound(b_hist.at<float>(i-1)) ) ,
             Point( bin_w*(i), hist_h - cvRound(b_hist.at<float>(i)) ),
             Scalar( 255, 0, 0), 2, 8, 0  );
    }
    
    /// 显示直方图
    namedWindow("calcHist Demo", CV_WINDOW_AUTOSIZE );
    imshow("calcHist Demo", histImage );
    
//    waitKey(0);
    
    return 0;
    
}

void produceBinaries(MyImage *m){
    Scalar lowerBound;
    Scalar upperBound;
    Mat foo;
    m->bwList.clear();
//    avgColor[0][0] = 17;
//    avgColor[0][1] = 95;
//    avgColor[0][2] = 125;
//    avgColor[1][0] = 17;
//    avgColor[1][1] = 96;
//    avgColor[1][2] = 123;
//    avgColor[2][0] = 17;
//    avgColor[2][1] = 94;
//    avgColor[2][2] = 116;
//    avgColor[3][0] = 18;
//    avgColor[3][1] = 101;
//    avgColor[3][2] = 117;
//    avgColor[4][0] = 17;
//    avgColor[4][1] = 105;
//    avgColor[4][2] = 122;
//    avgColor[5][0] = 18;
//    avgColor[5][1] = 106;
//    avgColor[5][2] = 121;
//    avgColor[6][0] = 14;
//    avgColor[6][1] = 78;
//    avgColor[6][2] = 155;
    // above is old
//    avgColor[0][1] = 213;
//    avgColor[0][2] = 225;
//    avgColor[1][0] = 17;
//    avgColor[1][1] = 173;
//    avgColor[1][2] = 148;
//    avgColor[2][0] = 16;
//    avgColor[2][1] = 219;
//    avgColor[2][2] = 234;
//    avgColor[3][0] = 13;
//    avgColor[3][1] = 195;
//    avgColor[3][2] = 178;
//    avgColor[4][0] = 14;
//    avgColor[4][1] = 211;
//    avgColor[4][2] = 215;
//    avgColor[5][0] = 13;
//    avgColor[5][1] = 211;
//    avgColor[5][2] = 249;
//    avgColor[6][0] = 17;
//    avgColor[6][1] = 167;
//    avgColor[6][2] = 136;
//    c_lower[0][0] = 12;
//    c_lower[0][1] = 30;
//    c_lower[0][2] = 80;
//    c_lower[1][0] = 12;
//    c_lower[1][1] = 30;
//    c_lower[1][2] = 80;
//    c_lower[2][0] = 12;
//    c_lower[2][1] = 30;
//    c_lower[2][2] = 80;
//    c_lower[3][0] = 12;
//    c_lower[3][1] = 30;
//    c_lower[3][2] = 80;
//    c_lower[4][0] = 12;
//    c_lower[4][1] = 30;
//    c_lower[4][2] = 80;
//    c_lower[5][0] = 12;
//    c_lower[5][1] = 30;
//    c_lower[5][2] = 80;
//    c_lower[6][0] = 12;
//    c_lower[6][1] = 30;
//    c_lower[6][2] = 80;
//    c_upper[0][0] = 7;
//    c_upper[0][1] = 40;
//    c_upper[0][2] = 30;
//    c_upper[1][0] = 7;
//    c_upper[1][1] = 40;
//    c_upper[1][2] = 30;
//    c_upper[2][0] = 7;
//    c_upper[2][1] = 36;
//    c_upper[2][2] = 21;
//    c_upper[3][0] = 7;
//    c_upper[3][1] = 40;
//    c_upper[3][2] = 30;
//    c_upper[4][0] = 7;
//    c_upper[4][1] = 40;
//    c_upper[4][2] = 30;
//    c_upper[5][0] = 7;
//    c_upper[5][1] = 40;
//    c_upper[5][2] = 6;
//    c_upper[6][0] = 7;
//    c_upper[6][1] = 40;
//    c_upper[6][2] = 30;
    
    
//
//    avgColor[0][0] = 15;
//    avgColor[0][1] = 132;
//    avgColor[0][2] = 87;
//    
//    avgColor[1][0] = 14;
//    avgColor[1][1] = 130;
//    avgColor[1][2] = 94;
//    
//    avgColor[2][0] = 13;
//    avgColor[2][1] = 155;
//    avgColor[2][2] = 91;
//    
//    avgColor[3][0] = 13;
//    avgColor[3][1] = 144;
//    avgColor[3][2] = 98;
//    
//    avgColor[4][0] = 13;
//    avgColor[4][1] = 134;
//    avgColor[4][2] = 86;
//    
//    avgColor[5][0] = 13;
//    avgColor[5][1] = 136;
//    avgColor[5][2] = 90;
//    
//    avgColor[6][0] = 14;
//    avgColor[6][1] = 140;
//    avgColor[6][2] = 99;
    
//    const int diff = 0;
//    for (int i = 0; i < NSAMPLES; i++) {
//        c_lower[i][0] = 12 - diff;
//        c_lower[i][1] = 30 - diff;
//        c_lower[i][2] = 80 - diff;
//        
//        c_upper[1][0] = 7 + diff;
//        c_upper[1][1] = 40 + diff;
//        c_upper[1][2] = 80 + diff;
//    }
//    const int diff1 = 30;
#if 0
    // 增加调试信息
    imshow("srclr", m->srcLR);
    myhist3(m->srcLR);
#endif
    for(int i=0;i<NSAMPLES;i++) {
        normalizeColors();
//        lowerBound=Scalar( 0, 129, 147);
//        upperBound=Scalar( 30, 200, 255);
//        lowerBound=Scalar( 0, 129, avgColor[i][2] - c_lower[i][2] - diff1);
//        upperBound=Scalar( 30, 200, avgColor[i][2] + c_upper[i][2] + diff1);
//        lowerBound=Scalar( 0, avgColor[i][1] - c_lower[i][1] - diff1, 0);
//        upperBound=Scalar( 30, avgColor[i][1] + c_upper[i][1] + diff1, 255);
        lowerBound=Scalar( avgColor[i][0] - c_lower[i][0] - diff1, avgColor[i][1] - c_lower[i][1] - diff1, avgColor[i][2] - c_lower[i][2] - diff1);
        upperBound=Scalar( avgColor[i][0] + c_upper[i][0] + diff1, avgColor[i][1] + c_upper[i][1] + diff1, avgColor[i][2] + c_upper[i][2] + diff1);
        m->bwList.push_back(Mat(m->srcLR.rows,m->srcLR.cols,CV_8U));
//        cout << "lowerBound for i" << i << ", " << lowerBound << endl;
//        cout << "upperBound for i" << i << ", " << upperBound << endl;
        inRange(m->srcLR,lowerBound,upperBound,m->bwList[i]);
    }
    m->bwList[0].copyTo(m->bw);

#if 0
    for(int i=1;i<NSAMPLES;i++){
        m->bw+=m->bwList[i];
        int aa = i;
        stringstream ss;
        ss<<aa;
        string s1 = ss.str();
        cout<<s1<<endl; // 30
        imshow("bw"+s1, m->bwList[i]);
    }
#endif
    
    
#if 1
//    medianBlur(m->bw, m->bw, 5);
    
    int dilation_type;
//    if( dilation_elem == 0 ){ dilation_type = MORPH_RECT; }
//    else if( dilation_elem == 1 ){ dilation_type = MORPH_CROSS; }
//    else if( dilation_elem == 2) { dilation_type = MORPH_ELLIPSE; }
    dilation_type = MORPH_ELLIPSE;
    double dilation_size = 3;
    double erosion_size = 3;
    double scale = 1.f;
#if kUseLowResolution
    scale = kLowResolutionLongSize / 1280.f;
    //         scale = 320.f / 1280.f;
    dilation_size *= scale;
    erosion_size *= scale;
#endif
    
    Mat element = getStructuringElement( dilation_type,
                                        Size( 2*dilation_size + 1, 2*dilation_size+1 ),
                                        Point( dilation_size, dilation_size ) );
    
    int erosion_type;
//    if( erosion_elem == 0 ){ erosion_type = MORPH_RECT; }
//    else if( erosion_elem == 1 ){ erosion_type = MORPH_CROSS; }
//    else if( erosion_elem == 2) { erosion_type = MORPH_ELLIPSE; }
    erosion_type = MORPH_ELLIPSE;
    Mat erosion_element = getStructuringElement( erosion_type,
                                        Size( 2*erosion_size + 1, 2*erosion_size+1 ),
                                        Point( erosion_size, erosion_size ) );
    
    /// 腐蚀操作
    
//    imshow("before dilate", m->bw);
    
//    erode( m->bw, m->bw, erosion_element );

    dilate(m->bw, m->bw, element);
    erode( m->bw, m->bw, erosion_element );
#if 0
    dilate(m->bw, m->bw, element);
    erode( m->bw, m->bw, erosion_element );
#endif
    dilate(m->bw, m->bw, element);

    medianBlur(m->bw, m->bw, 5);
//    imshow("after dilate", m->bw);
#endif
}

void initWindows(MyImage m){
    namedWindow("trackbars",CV_WINDOW_KEEPRATIO);
    namedWindow("img1",CV_WINDOW_FULLSCREEN);
}

void showWindows(MyImage m){
#if 1
    
    
#if 1
        pyrDown(m.bw,m.bw);
        pyrDown(m.bw,m.bw);
        Rect roirect( Point( 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   *m.src.cols/4,0 ), m.bw.size());
#else
        //    pyrDown(m.bw,m.bw);
        //    pyrDown(m.bw,m.bw);
        Rect roirect( Point( 0                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   *m.src.cols/1,0 ), m.bw.size());
#endif
    

    vector<Mat> channels;
    Mat result;
    for(int i=0;i<3;i++)
        channels.push_back(m.bw);
    merge(channels,result);
    
//    int i = result.channels();
    
//    OutputArray _dst = m.src(roirect);
//    int dtype = _dst.type();
//    int j = CV_MAT_CN(dtype);
//    printf("i=%d", i);
    result.copyTo(m.src(roirect));
#endif
#ifndef __OBJC__
    imshow("img1",m.src);
#endif
}

// ok
int findBiggestContour(vector<vector<Point> > contours){
    int indexOfBiggestContour = -1;
    int sizeOfBiggestContour = 0;
    for (int i = 0; i < contours.size(); i++){
        if(contours[i].size() > sizeOfBiggestContour){
            sizeOfBiggestContour = (int) contours[i].size();
            indexOfBiggestContour = i;
        }
    }
    return indexOfBiggestContour;
}

//Point middlePoint(Point p1, Point p2)
//{
//    return Point((p1.x+p2.x)/2, (p1.y+p2.y)/2 );
//}
//double distanceOfPoint(Point p1, Point p2)
//{
//    return  sqrt((pow((p1.x - p2.x),2) +  pow((p1.y - p2.y),2)));
//}

//Point vectorBetweenPoints(Point p1, Point p2)
//{
//    return Point((p1.x - p2.x) ,(p1.y - p2.y));
//}

void reduceDefect(HandGesture * hg)
{
      vector<Vec4i>::iterator d=hg->defects[hg->cIdx].begin();
     int count = (int)hg->defects[hg->cIdx].size();
    int i = 0;
     while( d!=hg->defects[hg->cIdx].end() ) {
         if (i==count - 2) {
         
         Vec4i& v=(*d);
         int startidx=v[0];
         Point ptStart(hg->contours[hg->cIdx][startidx] );
             
         int endidx=v[1];
         Point ptEnd(hg->contours[hg->cIdx][endidx] );
         int faridx=v[2];
         Point ptFar(hg->contours[hg->cIdx][faridx] );
             
         double disSF = distanceOfPoint(ptStart, ptFar);
         double scale = 1.f;
#if kUseLowResolution
         scale = kLowResolutionLongSize / 1280.f;
//         scale = 320.f / 1280.f;
#endif
         if(disSF < 100 * scale)
         {

//
             Point ptMid = middlePoint(ptStart, ptEnd);
             
             vector<Vec4i>::iterator e = d-1;
             Vec4i& t = (*e);
             int endidx=t[1];
             if(endidx < hg->contours[hg->cIdx].size())
             {
                 hg->contours[hg->cIdx][endidx] = ptMid;
                 //
                 //             e = d+1;
                 //             t = (*e);
                 //             int startidx=t[0];
                 //             hg->contours[hg->cIdx][startidx] = ptMid;
                 //
                 hg->defects[hg->cIdx].erase(d++);
                 continue;
             }

             
//
         }
         }
        d++;
         i++;
     }
}

double vectorAngle(Point vec)
{
    if (vec.x==0) {
        vec.x+=1;
    }
    
    double b =  atan(vec.y/vec.x);
    if(vec.x <= 0 && vec.y>0)
        b += M_PI;
    else if(vec.x <0 && vec.y<=0)
        b += M_PI ;
    if (vec.y<0 && vec.x>=0) {
        b += M_PI * 2;
    }
    return b;
}

//double vectorCrossAngle(Point p1, Point p2)
//{
//    double dotProduct =  ( p1.x * p2.x + p1.y * p2.y );
// 
//    double m = sqrt(p1.x*p1.x + p1.y*p1.y) * sqrt(p2.x*p2.x + p2.y*p2.y);
// 
//    return acos(dotProduct/m);
//}

Point vectorMultiply(Point vector ,float multi)
{
    return Point(vector.x * multi , vector.y * multi);
}

Point pointMove(Point point ,Point vector)
{
    return Point(vector.x + point.x , vector.y + point.y);
}

void caculateRingPosition(HandGesture *hg)
{
    Point ptStart(hg->mediusFinger[0]);
    Point ptFar(hg->mediusFinger[1]);
    Point ptEnd(hg->mediusFinger[2]);
    
    double distanceStart = distanceOfPoint(ptStart, ptFar);
    double distanceEnd = distanceOfPoint(ptEnd, ptFar);

    if(distanceStart > distanceEnd)
    {
        double ratio = distanceStart/distanceEnd;
        
        Point vectorEndFar = vectorBetweenPoints(ptEnd,ptFar);
        vectorEndFar = vectorMultiply(vectorEndFar,ratio);
        
        ptEnd = pointMove(ptFar, vectorEndFar);
    }
    else
    {
        double ratio = distanceEnd/distanceStart;
        
        Point vectorStartFar = vectorBetweenPoints(ptStart,ptFar);
        vectorStartFar = vectorMultiply(vectorStartFar,ratio);
        
        ptStart = pointMove(ptFar, vectorStartFar);
    }

    Point midPoint = middlePoint(ptStart, ptEnd);
    Point vectorMidFar = vectorBetweenPoints(ptFar, midPoint);
    vectorMidFar = vectorMultiply(vectorMidFar,0.12);
    
    Point ringStart;
    Point ringEnd;
    ringStart = pointMove(ptStart, vectorMidFar);
    ringEnd = pointMove(ptEnd, vectorMidFar);
    
    hg->ringWidth = distanceOfPoint(ringStart, ringEnd);
    hg->ringCenter = middlePoint(ringStart,ringEnd);
    
    Point ringVec = vectorBetweenPoints(ringStart, ringEnd);
    if (ringVec.x == 0) {
        hg->ringAngle = M_PI_2;
    } else {
        hg->ringAngle = abs(atan((ringVec.y)/(ringVec.x)));

    }
    
    Point vecMidFinger = vectorBetweenPoints(hg->mediusFinger[0], hg->mediusFinger[1]);
    if (vecMidFinger.x < 0) {
        hg->ringAngle *= -1;
    }
    
    hg->ringPosition.push_back(ringStart);
    hg->ringPosition.push_back(ringEnd);
}

//detect if rotation clockwise
int detectRotationDirection(HandGesture *hg)
{
    
    //根据食指和无名指顶点连线 和 中指中轴线的倾斜角度判断旋转方向
    Point2i firstTip1 = (*firstFingerTipFeatures)[0];
    //Point2i firstTip2 = (*firstFingerTipFeatures)[1];
    Point2i firstTip3 = (*firstFingerTipFeatures)[2];
    
    Point2i tip1 = hg->fingerTipFeatures[0];
    Point2i tip2 = hg->fingerTipFeatures[1];
    Point2i tip3 = hg->fingerTipFeatures[2];
    
    Point2i tipsVec = vectorBetweenPoints(tip1, tip3);
    Point2i firstTipsVec = vectorBetweenPoints(firstTip1, firstTip3);
    
    Point ptFirstStart((*firstFinger)[0] );
    Point ptFirstFar((*firstFinger)[1]  );
    Point ptFirstEnd((*firstFinger)[2]  );
    
    Point ptFirstMid = middlePoint(ptFirstStart, ptFirstFar);
    
    Point2i firstFingerEndVec = vectorBetweenPoints(ptFirstMid , ptFirstFar);
    
//    double firstfeatureAngle = vectorAngle(firstTipsVec)-vectorAngle(firstFingerEndVec);
    
    double firstfeatureAngle = vectorAngle(firstTipsVec);
    
    double firstdist1 = distanceOfPoint(ptFirstStart, ptFirstFar);
    double firstdist2 = distanceOfPoint(ptFirstEnd, ptFirstFar);

//  double firstdist3 = distanceOfPoint(ptFirstStart, ptFirstEnd);
//  Point vectorFirstStart = vectorBetweenPoints(ptFirstStart, ptFirstFar);
//  Point vectorFirstEnd = vectorBetweenPoints(ptFirstEnd, ptFirstFar);
    
    Point ptStart(hg->mediusFinger[0]);
    Point ptFar(hg->mediusFinger[1]);
    Point ptEnd(hg->mediusFinger[2]);
    
    Point ptMid = middlePoint(ptStart, ptEnd);
    
    Point2i fingerEndVec = vectorBetweenPoints(ptMid, ptFar);
  double featureAngle = vectorAngle(tipsVec)-vectorAngle(fingerEndVec);

//    double featureAngle = vectorAngle(tipsVec);
    if(featureAngle > firstfeatureAngle)
    {
//        rotationAngleY = 0 - rotationAngleY;
        return 1;
    }else{
        return 0;
    }
}

void caculateRotationAngle(HandGesture *hg)
{
    Point2i ringStart = hg->ringPosition[0];
    Point2i ringEnd = hg->ringPosition[1];
    
//    Point2i tip1 = hg->fingerTipFeatures[0];
//    Point2i tip2 = hg->fingerTipFeatures[1];
//    Point2i tip3 = hg->fingerTipFeatures[2];
//    
//    Point2i vec1 = vectorBetweenPoints(tip1, ringStart);
//    Point2i vec2 = vectorBetweenPoints(tip2, ringStart);
//    
//    double angle1 = vectorCrossAngle(vec1,vec2);
//    
//    vec1 = vectorBetweenPoints(tip2, ringEnd);
//    vec2 = vectorBetweenPoints(tip3, ringEnd);
//    
//    double angle2 = vectorCrossAngle(vec1, vec2);
//
//    hg->featureAngles.push_back(angle1);
//    hg->featureAngles.push_back(angle2);

    if(hg->index==1)
    {
        if (firstFingerTipFeatures) {
            delete firstFingerTipFeatures;
        }
        if (firstFeatureAngles) {
            delete firstFeatureAngles;
        }
        //firstFeatureAngles = new vector<Point>(hg->featureAngles);
        firstFingerTipFeatures = new vector<Point2i>(hg->fingerTipFeatures);
        firstFeatureAngles = new vector<double>(hg->featureAngles);
        firstFingerCrossAngles = new vector<double>(hg->fingerCrossAngles);
        //firstFeatureAngles = &hg->featureAngles;
        return;
    }
    
    //angle1 = hg->featureAngles[0] / 2;
    //angle2 = hg->featureAngles[1] / 2;
    
    double angle1, angle2, angle3;
    
    angle1 = hg->fingerCrossAngles[0];
    angle2 = hg->fingerCrossAngles[1];
    angle3 = hg->fingerCrossAngles[2];
    double angle = (angle1 + angle2 + angle3) / 3;
    
    if(!firstFeatureAngles)
    {
        hg->rotationAngle.clear();
        hg->rotationAngle.push_back(0);
        hg->rotationAngle.push_back(0);
        hg->rotationAngle.push_back(0);
        return;
    }
    
    dprintf("firstFingerCrossAngles 1 :%f 2 :%f\n", (*firstFingerCrossAngles)[0] * 180/ M_PI, (*firstFingerCrossAngles)[1] * 180/ M_PI);
    
    dprintf("fingerCrossAngles 1 :%f 2 :%f\n", angle1 * 180/ M_PI, angle2 * 180/ M_PI);
//    double firstAngle1 = (*firstFeatureAngles)[0] / 2;
//    double firstAngle2 = (*firstFeatureAngles)[1] / 2;
    double firstAngle1 = (*firstFingerCrossAngles)[0];
    double firstAngle2 = (*firstFingerCrossAngles)[1];
    double firstAngle3 = (*firstFingerCrossAngles)[2];
    double firstAngle = (firstAngle1 + firstAngle2 + firstAngle3)/3;
    
    double rotantionAngle = acos(angle/firstAngle);
    if (isnan(rotantionAngle)) {
        rotantionAngle = 0;
    }
    
//    double rotationAngle1 = acos(tan(angle1)/tan(firstAngle1));
//    
//    if (isnan(rotationAngle1)) {
//        rotationAngle1 = 0;
//    }
//    double rotationAngle2 = acos(tan(angle2)/tan(firstAngle2));
//    
//    if(isnan(rotationAngle2)){
//        rotationAngle2 = 0;
//    }
    
      double rotationAngleY = rotantionAngle;
//    double rotationAngleY = (rotationAngle1 + rotationAngle2)/2;
    
//    Point2i firstTip1 = (*firstFingerTipFeatures)[0];
////  Point2i firstTip2 = (*firstFingerTipFeatures)[1];
//    Point2i firstTip3 = (*firstFingerTipFeatures)[2];
//    
//    Point2i firstTipsVec = vectorBetweenPoints(firstTip1, firstTip3);
//    Point2i tipsVec = vectorBetweenPoints(tip1, tip3);
//    
// 
//    Point ptFirstStart((*firstFinger)[0] );
//    Point ptFirstFar((*firstFinger)[1]  );
//    Point ptFirstEnd((*firstFinger)[2]  );
//    
//    Point2i firstFingerEndVec = vectorBetweenPoints(ptFirstStart, ptFirstEnd);
//    
//    double firstfeatureAngle = vectorAngle(firstTipsVec)-vectorAngle(firstFingerEndVec);
//    
//    double firstdist1 = distanceOfPoint(ptFirstStart, ptFirstFar);
//    double firstdist2 = distanceOfPoint(ptFirstEnd, ptFirstFar);
////    double firstdist3 = distanceOfPoint(ptFirstStart, ptFirstEnd);
//    
//    Point vectorFirstStart = vectorBetweenPoints(ptFirstStart, ptFirstFar);
//    Point vectorFirstEnd = vectorBetweenPoints(ptFirstEnd, ptFirstFar);
//    
//    Point ptStart(hg->mediusFinger[0]);
//    Point ptFar(hg->mediusFinger[1]);
//    Point ptEnd(hg->mediusFinger[2]);
//    
//    Point2i fingerEndVec = vectorBetweenPoints(ptStart, ptEnd);
//    
//    double featureAngle = vectorAngle(tipsVec)-vectorAngle(fingerEndVec);
//    if(featureAngle > firstfeatureAngle)
//    {
//        rotationAngleY = 0 - rotationAngleY;
//    }
    
    if(detectRotationDirection(hg)==0)
    {
        rotationAngleY = 0 - rotationAngleY;
    }
    
//    double dist1 = distanceOfPoint(ptStart, ptFar);
//    double dist2 = distanceOfPoint(ptEnd, ptFar);
////    double dist3 = distanceOfPoint(ptStart, ptEnd);
//    
//    Point vectorStart = vectorBetweenPoints(ptStart, ptFar);
//    Point vectorEnd = vectorBetweenPoints(ptEnd, ptFar);
//    
//    double scale1 = dist1 / firstdist1;
//    double scale2 = dist2 / firstdist2;
////    double scale3 = dist3 / firstdist3;
//    
//    double rotationAngleZ1 = vectorCrossAngle(vectorFirstStart, vectorStart);
//    double rotationAngleZ2 = vectorCrossAngle(vectorFirstEnd, vectorEnd);
//    double rotationAngleZ = MAX(rotationAngleZ1, rotationAngleZ2);
    
//    double scale = max(scale1, scale2);
//    
//    double rotationAngleX = acos(scale);
//    if (scale>1.0) {
//        rotationAngleX = 0;
//    }
//    rotationAngleX  = 0;
//    double rotationAngleY = acos(scale3);
    
    double rotationAngleX = 0;
    double rotationAngleZ = 0;

    hg->rotationAngle.clear();
    hg->rotationAngle.push_back(rotationAngleX);
    hg->rotationAngle.push_back(rotationAngleY);
    hg->rotationAngle.push_back(rotationAngleZ);
    
    printf("rotationAngle X :%f Y :%f Z :%f\n", rotationAngleX * 180/ M_PI, rotationAngleY * 180/ M_PI ,rotationAngleZ * 180/ M_PI);
}

void ajustFinger(HandGesture *hg)
{
    Point ptStart(hg->mediusFinger[0]);
    Point ptFar(hg->mediusFinger[1]);
    Point ptEnd(hg->mediusFinger[2]);
    
    double distanceStart = distanceOfPoint(ptStart, ptFar);
    double distanceEnd = distanceOfPoint(ptEnd, ptFar);
    
    if(distanceStart > distanceEnd)
    {
        
    }
    
    
}

void myDrawContours(MyImage *m,HandGesture *hg){
    drawContours(m->src,hg->hullP,hg->cIdx,cv::Scalar(200,0,0),2, 8, vector<Vec4i>(), 0, Point());
    
    rectangle(m->src,hg->bRect.tl(),hg->bRect.br(),Scalar(0,0,200));
    vector<Vec4i>::iterator d=hg->defects[hg->cIdx].begin();
    //	int fontFace = FONT_HERSHEY_PLAIN;
    
    
    vector<Mat> channels;
    Mat result;
    for(int i=0;i<3;i++)
        channels.push_back(m->bw);
    merge(channels,result);
    //	drawContours(result,hg->contours,hg->cIdx,cv::Scalar(0,200,0),6, 8, vector<Vec4i>(), 0, Point());
//    drawContours(result,hg->hullP,hg->cIdx,cv::Scalar(0,0,250),10, 8, vector<Vec4i>(), 0, Point());
    
    
//    reduceDefect(hg);
    
    int i = 0;
    int count = (int)hg->defects[hg->cIdx].size();
    while( d!=hg->defects[hg->cIdx].end() ) {
//        if(i==2)
        {
        
   	    Vec4i& v=(*d);
        int startidx=v[0];
        Point ptStart(hg->contours[hg->cIdx][startidx] );
        int endidx=v[1];
        Point ptEnd(hg->contours[hg->cIdx][endidx] );
        int faridx=v[2];
        Point ptFar(hg->contours[hg->cIdx][faridx] );
        //        float depth = v[3] / 256;
        
        float scale = 1.0f;
#ifndef __OBJC__
        scale = 1.0f;
#else
        scale = 1.0f;
#endif
            double val =(double) i / (double)count * 255.f;
            Scalar scalar = Scalar(val,val,val);
//        line( m->src, ptStart, ptFar, Scalar(0,255,0), 1 *scale);
//        line( m->src, ptEnd, ptFar, Scalar(0,255,0), 1 * scale);
//        circle( m->src, ptFar,   4, Scalar(0,255,0), 2 * scale);
//        circle( m->src, ptEnd,   4, Scalar(0,0,255), 2 * scale);
//        circle( m->src, ptStart,   4, Scalar(255,0,0), 2 * scale);
#if kDevelop
            line( m->src, ptStart, ptFar, scalar, 1 *scale);
            line( m->src, ptEnd, ptFar, scalar, 1 * scale);
            circle( m->src, ptFar,   4, scalar, 2 * scale);
            circle( m->src, ptEnd,   4, scalar, 2 * scale);
            circle( m->src, ptStart,   4, scalar, 2 * scale);
#endif
            
            
        if ( i == 0  ){//中指左侧的线条
            hg->mediusFinger.push_back(ptFar);
            hg->mediusFinger.push_back(ptStart);
#if kDevelop
            circle( m->src, ptFar, 4, Scalar(255,255,0), 2 * scale);
            circle( m->src, ptStart, 4, Scalar(255,255,0), 2 * scale);
            line( m->src, ptStart, ptFar, Scalar(255,255,0), 1 * scale);
#endif
            hg->fingerTipFeatures.push_back(ptStart);//旋转角度参考点
            hg->fingerTipFeatures.push_back(ptEnd);
#if kDevelop
            circle( m->src, ptStart, 4, Scalar(255,255,0), 2 * scale);
            circle( m->src, ptEnd, 4, Scalar(255,255,0), 2 * scale);
#endif
            Point vecSF = vectorBetweenPoints(ptStart, ptFar);
            Point vecEF = vectorBetweenPoints(ptEnd, ptFar);
            double angle = vectorCrossAngle(vecSF,vecEF);
            
            hg->fingerCrossAngles.push_back(angle);
        }
            if(i==1)
            {
                Point vecSF = vectorBetweenPoints(ptStart, ptFar);
                Point vecEF = vectorBetweenPoints(ptEnd, ptFar);
                double angle = vectorCrossAngle(vecSF,vecEF);
                
                hg->fingerCrossAngles.push_back(angle);
            }
        if (i==count - 1) {//中指右侧的线条
            hg->mediusFinger.push_back(ptFar);
            circle( m->src, ptFar,   4, Scalar(0,255,255), 2 * scale);
            line( m->src, hg->mediusFinger[1], ptFar, Scalar(0,255,255), 1 * scale);
            
            Point vecSF = vectorBetweenPoints(ptStart, ptFar);
            Point vecEF = vectorBetweenPoints(ptEnd, ptFar);
            double angle = vectorCrossAngle(vecSF,vecEF);
            hg->fingerCrossAngles.push_back(angle);
            
            hg->fingerTipFeatures.push_back(ptStart);
            
            circle( m->src, ptStart,   4, Scalar(0,255,255), 2 * scale);
            if(hg->index==1)
            {
                if (firstFinger) {
                    delete firstFinger;
                }
                firstFinger = new vector<Point>(hg->mediusFinger);
                
                if (firstFeatureAngles) {
                    delete firstFeatureAngles;
                }
                firstFeatureAngles = new vector<double>();
                
                if (firstFingerCrossAngles) {
                    delete firstFingerCrossAngles;
                }
                firstFingerCrossAngles = new vector<double>();
                
                //firstFinger ->push_back(hg->mediusFinger[0]);
                //firstFinger ->push_back(hg->mediusFinger[1]);
                //firstFinger ->push_back(hg->mediusFinger[2]);
                //&hg->mediusFinger;
            }
            caculateRingPosition(hg);
            caculateRotationAngle(hg);
            
//            circle( m->src, hg->ringPosition[0],   4, Scalar(0,255,0), 2 * scale);
//            circle( m->src, hg->ringPosition[1],   4, Scalar(0,255,0), 2 * scale);
//            line( m->src, hg->ringPosition[0], hg->ringPosition[1], Scalar(0,255,0), 1 * scale);
        }
 
        /*
        IplImage* ringImg = cvLoadImage("/Users/sky/Desktop/gesture/testring1.png");
        Mat ringMat(ringImg);
        Rect roirect( Point( 0,0 ), ringMat.size());
        vector<Mat> channels;
        ringMat.copyTo( m->src(roirect));
        
         */
//        circle( result, ptFar,   9, Scalar(0,205,0), 5 );
        
        }
        d++;
        i++;
    }
    //	imwrite("./images/contour_defects_before_eliminate.jpg",result);
    int b = 0;
    b = 1;
}

void makeContours(MyImage *m, HandGesture* hg){
    Mat aBw;
    pyrUp(m->bw,m->bw);
    m->bw.copyTo(aBw);
    findContours(aBw,hg->contours,CV_RETR_EXTERNAL,CV_CHAIN_APPROX_NONE);
    hg->initVectors();
    hg->cIdx=findBiggestContour(hg->contours);
    if(hg->cIdx!=-1){
        //		approxPolyDP( Mat(hg->contours[hg->cIdx]), hg->contours[hg->cIdx], 11, true );
        hg->bRect=boundingRect(Mat(hg->contours[hg->cIdx]));
        convexHull(Mat(hg->contours[hg->cIdx]),hg->hullP[hg->cIdx],false,true);
        convexHull(Mat(hg->contours[hg->cIdx]),hg->hullI[hg->cIdx],false,false);
        approxPolyDP( Mat(hg->hullP[hg->cIdx]), hg->hullP[hg->cIdx], 18, true );
        if(hg->contours[hg->cIdx].size()>3 ){
            convexityDefects(hg->contours[hg->cIdx],hg->hullI[hg->cIdx],hg->defects[hg->cIdx]);
//            hg->eleminateDefects();
            //去除不是手指的凸包
            hg->reduceDefect();

        }
        hg->getFingerTips(m->src.rows);
        bool isHand=hg->detectIfHand();
//        hg->printGestureInfo();
//        isHand = true;
        if(isHand){
            hg->isHand = true;
            hg->drawFingerTips(m->src);
//            myDrawContours(m,hg);
        }else
        {
            hg->isHand = false;
        }
        myDrawContours(m,hg);
    }
}

IplImage * shrink(IplImage *input, double scale) {
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

void processOnImage(MyImage &m1, HandGesture &hg) {
    //        flip(m.src,m.src,1);
    pyrDown(m1.src,m1.srcLR);
    blur(m1.srcLR,m1.srcLR,Size(3,3));
    cvtColor(m1.srcLR,m1.srcLR,ORIGCOL2COL);
    produceBinaries(&m1);
    cvtColor(m1.srcLR,m1.srcLR,COL2ORIGCOL);
    makeContours(&m1, &hg);
    hg.getFingerNumber(m1.src);
    showWindows(m1);
}


void processOnImageWithShowImage(MyImage &m1, HandGesture &hg) {
    //        flip(m.src,m.src,1);
    pyrDown(m1.src,m1.srcLR);
    blur(m1.srcLR,m1.srcLR,Size(3,3));
    cvtColor(m1.srcLR,m1.srcLR,ORIGCOL2COL);
    produceBinaries(&m1);
    cvtColor(m1.srcLR,m1.srcLR,COL2ORIGCOL);
    makeContours(&m1, &hg);
    hg.getFingerNumber(m1.src);
    showWindows(m1);
}


MyImage* newMyImage(std::string fileName) {
    IplImage *pImg = cvLoadImage(fileName.c_str());
    pImg = shrink(pImg, 0.2);
    MyImage *m1 = new MyImage(pImg);
    return m1;
}

void on_mouse( int event, int x, int y, int flags, void* ustc)
{
//    char temp[16];
    CvPoint pt;
    CvFont font;
    cvInitFont(&font, CV_FONT_HERSHEY_SIMPLEX, 0.5, 0.5, 0, 1, CV_AA);
    
    if( event == CV_EVENT_MOUSEMOVE )
    {
//        cvCopy(dst,src);
//        sprintf(temp,"(%d,%d)",x,y);
//        pt = cvPoint(x,y);
//        cvPutText(src,temp, pt, &font, cvScalar(255, 255, 255, 0));
//        cvCircle( src, pt, 2,cvScalar(255,0,0,0) ,CV_FILLED, CV_AA, 0 );
//        cvShowImage( "src", src );
    }
    else if( event == CV_EVENT_LBUTTONDOWN )
    {
        //cvCopy(dst,src);
//        sprintf(temp,"(%d,%d)",x,y);
        pt = cvPoint(x,y);
//        cvPutText(src,temp, pt, &font, cvScalar(255, 255, 255, 0));
//        cvCircle( src, pt, 2,cvScalar(255,0,0,0) ,CV_FILLED, CV_AA, 0 );
//        cvCopy(src,dst);
//        cvShowImage( "src", src );
        dprintf("on_mouse x=%d, y=%d\n", x, y);
    }
}

MyImage * detectHand(IplImage *inputImage,  HandGesture &hg, int diff) {
    MyImage *m1 = new MyImage(inputImage);
    diff1 = diff;
//    findROIColorInPalm(inputImage);
    processOnImageWithShowImage(*m1, hg);
    return m1;
}

MyImage * detectHand(Mat *inputImage,  HandGesture &hg, int diff) {
    MyImage *m1 = new MyImage(inputImage);
    diff1 = diff;
    //    findROIColorInPalm(inputImage);
    processOnImageWithShowImage(*m1, hg);
    return m1;
}

int mymain(){

#if    kUseCamera
    MyImage m(0);
#else
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0611.JPG");
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0612.JPG");
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0613.JPG");
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0612.JPG");
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0612.JPG");
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0612.JPG");
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0612.JPG");

    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0824.JPG");
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0825.JPG");
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0828.JPG");
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0832.JPG");
    //    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0833.JPG");
    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0835.JPG");
//    Mat img(pImg,0); // 0是不複製影像，也就是pImg與img的data共用同個記憶體位置，header各自有
//    imshow("img11", img);
//    waitKey();
    dprintf("channels=%d, depth=%d", pImg->nChannels, pImg->depth);
    pImg = shrink(pImg, 0.2);
    MyImage m(pImg);
//    imshow("img12", m.src);
//
//    waitKey();
#endif

//    cvNamedWindow("src",1);
//    cvSetMouseCallback( "src", on_mouse, 0 );
//    cvShowImage("src", pImg);
//    cvWaitKey(0);
    
//    HandGesture hg;
    //	init(&m);
    if (kUseCamera) {
        m.cap >> m.src;
        pyrDown(m.src,m.src);
    }
#ifndef __OBJC__
    namedWindow("img1",CV_WINDOW_KEEPRATIO);
#endif
//    cvSetMouseCallback( "img1", on_mouse, 0 );
    VideoWriter out;
    out.open("out.avi", CV_FOURCC('M', 'J', 'P', 'G'), 15, m.src.size(), true);
    waitForPalmCover(&m);
//    average(&m);
#ifndef __OBJC__
    destroyWindow("img1");

    initWindows(m);
#endif
    initTrackbars();
    
#if kUseCamera
    for(;;)
#endif
    {
        HandGesture hg;
        hg.frameNumber++;
        if (kUseCamera) {
            m.cap >> m.src;
            pyrDown(m.src,m.src);
            flip(m.src,m.src,1);
        }
        pyrDown(m.src,m.srcLR);
        blur(m.srcLR,m.srcLR,Size(3,3));
        cvtColor(m.srcLR,m.srcLR,ORIGCOL2COL);
        produceBinaries(&m);
        cvtColor(m.srcLR,m.srcLR,COL2ORIGCOL);
        makeContours(&m, &hg);
        hg.getFingerNumber(m.src);
        showWindows(m);
//        out << m.src;
        
        //imwrite("./images/final_result.jpg",m.src);
//        if(cv::waitKey(30) == char('q')) break;
    }
    waitKey(0);
    {
        HandGesture hg;
        hg.frameNumber++;
        std::string fileNameBase = "/Users/sky/Desktop/gesture/IMG_08";
        for (int i = 24; i <= 34; ++i) {
            std::ostringstream s;
            s << fileNameBase << i << ".JPG";
            std::string fileName(s.str());
            cout<<"fileName="<<fileName<<endl;
            MyImage *m1 = newMyImage(fileName);
            HandGesture hg1;
            processOnImage(*m1, hg1);
            delete m1;
//            out << m.src;
            waitKey(0);
        }

        //imwrite("./images/final_result.jpg",m.src);
        //        if(cv::waitKey(30) == char('q')) break;
    }
   
//    {
//        hg.frameNumber++;
//        MyImage *m1 = newMyImage("/Users/sky/Desktop/gesture/IMG_0832.JPG");
//        processOnImage(*m1, hg);
//        delete m1;
//        out << m.src;
//        //imwrite("./images/final_result.jpg",m.src);
//        //        if(cv::waitKey(30) == char('q')) break;
//    }
//    waitKey(0);

    destroyAllWindows();
    out.release();
//    m.cap.release();
    return 0;
}
