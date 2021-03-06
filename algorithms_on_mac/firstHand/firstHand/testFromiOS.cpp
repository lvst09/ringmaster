//
//  testFromiOS.cpp
//  firstHand
//
//  Created by sky on 15/4/5.
//  Copyright (c) 2015年 NoName. All rights reserved.
//

#include "testFromiOS.h"
#include "mymain.hpp"
#include "handGesture.hpp"

//#include "test2.h"

// test 2
#include "opencv/cv.h"
#include "opencv2/highgui/highgui.hpp"
#include <iostream>
#include <stdio.h>
#include <math.h>
#include <string.h>
//#include <conio.h>

using namespace std;

using namespace cv;

/// 全局变量

static cv::Mat src, src_gray;
static cv::Mat dst, detected_edges;

static int edgeThresh = 1;
static int lowThreshold;
static int const max_lowThreshold = 100;
static int ratio = 3;
static int kernel_size = 3;
static char* window_name = "Edge Map";


using namespace cv;
using namespace std;

/// 全局变量
//Mat src;
static cv::Mat hsv;
static cv::Mat hue;
static int bins = 25;

/// 函数申明
void Hist_and_Backproj2(int, void* );

static int myhist(cv::Mat input);

/** @函数 main */
static int myback()
{
    /// 读取图像
    //    src = imread( argv[1], 1 );
    /// 转换到 HSV 空间
    cvtColor( src, hsv, CV_BGR2HSV );
    
    /// 分离 Hue 通道
    hue.create( hsv.size(), hsv.depth() );
    int ch[] = { 0, 0 };
    mixChannels( &hsv, 1, &hue, 1, ch, 1 );
    
    /// 创建 Trackbar 来输入bin的数目
    char* window_image = "Source image";
    namedWindow( window_image, CV_WINDOW_AUTOSIZE );
    createTrackbar("* Hue  bins: ", window_image, &bins, 180, Hist_and_Backproj2);
    Hist_and_Backproj2(0, 0);
    
    /// 现实图像
    imshow( window_image, src );
    
    /// 等待用户反应
    waitKey(0);
    return 0;
}


/**
 * @函数 Hist_and_Backproj
 * @简介：Trackbar事件的回调函数
 */
void Hist_and_Backproj2(int, void* )
{
    MatND hist;
    int histSize = MAX( bins, 2 );
    float hue_range[] = { 0, 180 };
    const float* ranges = { hue_range };
    
    /// 计算直方图并归一化
    calcHist( &hue, 1, 0, Mat(), hist, 1, &histSize, &ranges, true, false );
    normalize( hist, hist, 0, 255, NORM_MINMAX, -1, Mat() );
    
    /// 计算反向投影
    MatND backproj;
    calcBackProject( &hue, 1, 0, hist, backproj, &ranges, 1, true );
    
    /// 显示反向投影
    imshow( "BackProj", backproj );
    
    /// 显示直方图
    int w = 400; int h = 400;
    int bin_w = cvRound( (double) w / histSize );
    Mat histImg = Mat::zeros( w, h, CV_8UC3 );
    
    for( int i = 0; i < bins; i ++ )
    { rectangle( histImg, Point( i*bin_w, h ), Point( (i+1)*bin_w, h - cvRound( hist.at<float>(i)*h/255.0 ) ), Scalar( 0, 0, 255 ), -1 ); }
    
    imshow("Histogram", histImg);
}

/**
 * @函数 CannyThreshold
 * @简介： trackbar 交互回调 - Canny阈值输入比例1:3
 */
static void CannyThreshold(int, void*)
{
    /// 使用 3x3内核降噪
    blur( hue, detected_edges, Size(3,3) );
    
    /// 运行Canny算子
    Canny( detected_edges, detected_edges, lowThreshold, lowThreshold*3.0, kernel_size );
    
    /// 使用 Canny算子输出边缘作为掩码显示原图像
    dst = Scalar::all(0);
    
    src.copyTo( dst, detected_edges);
    imshow( window_name, dst );
    myhist(dst);
}


/** @函数 main */
int myhist(Mat input)
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
    
    waitKey(0);
    
    return 0;
    
}
/*
 *@brief rotate image by factor of 90 degrees
 *
 *@param source : input image
 *@param dst : output image
 *@param angle : factor of 90, even it is not factor of 90, the angle
 * will be mapped to the range of [-360, 360].
 * {angle = 90n; n = {-4, -3, -2, -1, 0, 1, 2, 3, 4} }
 * if angle bigger than 360 or smaller than -360, the angle will
 * be map to -360 ~ 360.
 * mapping rule is : angle = ((angle / 90) % 4) * 90;
 *
 * ex : 89 will map to 0, 98 to 90, 179 to 90, 270 to 3, 360 to 0.
 *
 */
void rotate_image_90n(cv::Mat &src, cv::Mat &dst, int angle)
{
    if(src.data != dst.data){
        src.copyTo(dst);
    }
    
    angle = ((angle / 90) % 4) * 90;
    
    //0 : flip vertical; 1 flip horizontal
    bool const flip_horizontal_or_vertical = angle > 0 ? 1 : 0;
    int const number = std::abs(angle / 90);
    
    for(int i = 0; i != number; ++i){
        cv::transpose(dst, dst);
        cv::flip(dst, dst, flip_horizontal_or_vertical);
    }
}
/** @函数 main */
int testFromiOS()
{
    /// 装载图像
//    src = imread("/Users/sky/Downloads/daily_delete/aaa/Movie12347.MOV_MYIMG_ORI0.JPG");
//    src = imread("/Users/sky/Downloads/daily_delete/MyVideo1428119600.MOV_MYIMG_ORI0.JPG");
    src = imread("/Users/sky/Downloads/daily_delete/MYIMG_ORI2.JPG");
//    src = imread("/Users/sky/Downloads/daily_delete/MyVideo1428119600.MOV_MYIMG_ORI0_1.png");

//    image = [ImageProcess correctImage:image];
//    IplImage *ipImage = convertIplImageFromUIImage(image);
    rotate_image_90n(src, src, 180);
//    imshow("abd1", src);
//    /// 等待用户反应
//    waitKey(0);
    findROIColorInPalm(&src);
    imshow("abd2", src);
    /// 等待用户反应
//    waitKey(0);
    HandGesture *hg = new HandGesture();
    
    MyImage * myImage = detectHand(&src, *hg, 30);
    imshow("abd3", myImage->src);
    /// 等待用户反应
    waitKey(0);
    return 0;
//    myhist(src);
    //    myback();
    /// 等待用户反应
    //    waitKey(0);
    
    //    return 0;
    if( !src.data )
    { return -1; }
    
    Mat threshold_output;
    
    /// 创建与src同类型和大小的矩阵(dst)
    dst.create( src.size(), src.type() );
    
    
    cvtColor( src, hsv, CV_BGR2HSV );
    
    /// 分离 Hue 通道
    hue.create( hsv.size(), hsv.depth() );
    int ch[] = { 0, 0 };
    mixChannels( &hsv, 1, &hue, 1, ch, 1 );
    
    /// 原图像转换为灰度图像
    //    cvtColor( hsv, src_gray, CV _BGR2GRAY );
    //    for (int i = 0; i < 255; ++i) {
    //        threshold(hue, threshold_output, i, 255, THRESH_BINARY );
    //        int aa = i;
    //        stringstream ss;
    //        ss<<aa;
    //        string s1 = ss.str();
    //        cout<<s1<<endl; // 30
    //
    //        string s2 = "/Users/sky/Downloads/daily_delete/Gray_Image" + s1 + ".jpg";
    //        ss>>s2;
    //        cout<<s2<<endl; // 30
    //        imwrite("/Users/sky/Downloads/daily_delete/Gray_Image" + s1 + ".jpg", threshold_output);
    //    }
    //    threshold(hue, threshold_output, 0, 255, THRESH_OTSU );
    //    imshow("calcHist Demo", threshold_output );
    
    /// 创建显示窗口
    namedWindow( window_name, CV_WINDOW_AUTOSIZE );
    
    //    imshow("abc", threshold_output);
    /// 创建trackbar
    createTrackbar( "Min Threshold:", window_name, &lowThreshold, max_lowThreshold, CannyThreshold );
    
    /// 显示图像
    CannyThreshold(0, 0);
    
    /// 等待用户反应
    waitKey(0);
    
    return 0;
}
