//
//  test2.cpp
//  firstHand
//
//  Created by sky on 15/4/5.
//  Copyright (c) 2015年 NoName. All rights reserved.
//

#include "test2.h"

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

int edgeThresh = 1;
int lowThreshold;
int const max_lowThreshold = 100;
int ratio = 3;
int kernel_size = 3;
char* window_name = "Edge Map";


using namespace cv;
using namespace std;

/// 全局变量
//Mat src;
static cv::Mat hsv; cv::Mat hue;
int bins = 25;

/// 函数申明
void Hist_and_Backproj(int, void* );


/** @函数 main */
int myback()
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
    createTrackbar("* Hue  bins: ", window_image, &bins, 180, Hist_and_Backproj );
    Hist_and_Backproj(0, 0);
    
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
void Hist_and_Backproj(int, void* )
{
    MatND hist;
    int histSize = MAX( bins, 2 );
    float hue_range[] = { 0, 180 };
    const float* ranges = { hue_range };
    
    /// 计算直方图并归一化
    calcHist( &hue, 1, 0, cv::Mat(), hist, 1, &histSize, &ranges, true, false );
    normalize( hist, hist, 0, 255, NORM_MINMAX, -1, cv::Mat() );
    
    /// 计算反向投影
    MatND backproj;
    calcBackProject( &hue, 1, 0, hist, backproj, &ranges, 1, true );
    
    /// 显示反向投影
    imshow( "BackProj", backproj );
    
    /// 显示直方图
    int w = 400; int h = 400;
    int bin_w = cvRound( (double) w / histSize );
    cv::Mat histImg = cv::Mat::zeros( w, h, CV_8UC3 );
    
    for( int i = 0; i < bins; i ++ )
    { rectangle( histImg, Point( i*bin_w, h ), Point( (i+1)*bin_w, h - cvRound( hist.at<float>(i)*h/255.0 ) ), Scalar( 0, 0, 255 ), -1 ); }
    
    imshow("Histogram", histImg);
}

/**
 * @函数 CannyThreshold
 * @简介： trackbar 交互回调 - Canny阈值输入比例1:3
 */
void CannyThreshold(int, void*)
{
    /// 使用 3x3内核降噪
    blur( hue, detected_edges, Size(3,3) );
    
    /// 运行Canny算子
    Canny( detected_edges, detected_edges, lowThreshold, lowThreshold*3.0, kernel_size );
    
    /// 使用 Canny算子输出边缘作为掩码显示原图像
    dst = Scalar::all(0);
    
    src.copyTo( dst, detected_edges);
    imshow( window_name, dst );
//    myhist(&dst);
}


/** @函数 main */
int myhist(cv::Mat *input)
{
//    Mat src, dst;
//    
//    /// 装载图像
//    src = imread( argv[1], 1 );
    
    if( !input->data )
    { return -1; }
    
    /// 分割成3个单通道图像 ( R, G 和 B )
    vector<cv::Mat> rgb_planes;
    split( *input, rgb_planes );
    
    /// 设定bin数目
    int histSize = 255;
    
    /// 设定取值范围 ( R,G,B) )
    float range[] = { 0, 255 } ;
    const float* histRange = { range };
    
    bool uniform = true; bool accumulate = false;
    
    cv::Mat r_hist, g_hist, b_hist;
    
    /// 计算直方图:
    calcHist( &rgb_planes[0], 1, 0, cv::Mat(), r_hist, 1, &histSize, &histRange, uniform, accumulate );
    calcHist( &rgb_planes[1], 1, 0, cv::Mat(), g_hist, 1, &histSize, &histRange, uniform, accumulate );
    calcHist( &rgb_planes[2], 1, 0, cv::Mat(), b_hist, 1, &histSize, &histRange, uniform, accumulate );
    
    // 创建直方图画布
    int hist_w = 400; int hist_h = 400;
    int bin_w = cvRound( (double) hist_w/histSize );
    
    cv::Mat histImage( hist_w, hist_h, CV_8UC3, Scalar( 0,0,0) );
    
    /// 将直方图归一化到范围 [ 0, histImage.rows ]
    normalize(r_hist, r_hist, 0, histImage.rows, NORM_MINMAX, -1, cv::Mat() );
    normalize(g_hist, g_hist, 0, histImage.rows, NORM_MINMAX, -1, cv::Mat() );
    normalize(b_hist, b_hist, 0, histImage.rows, NORM_MINMAX, -1, cv::Mat() );
    
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

/** @函数 main */
int test2main()
{
    /// 装载图像
    src = imread("/Users/sky/Downloads/daily_delete/aaa/Movie12347.MOV_MYIMG_ORI0.JPG");
    myhist(&src);
//    myback();
    /// 等待用户反应
//    waitKey(0);
    
//    return 0;
    if( !src.data )
    { return -1; }
    
    cv::Mat threshold_output;
    
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
