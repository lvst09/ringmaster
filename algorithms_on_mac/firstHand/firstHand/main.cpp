#if 0
//VERSION: HAND DETECTION 1.0

//AUTHOR: ANDOL LI@CW3/18, Live:lab

//PROJECT: HAND DETECTION PROTOTYPE

//LAST UPDATED: 03/2009



#include <opencv/cv.h>
#include <opencv/cxcore.h>
#include <opencv/highgui.h>


#include "math.h"

#include <iostream>

#include <stdio.h>

#include <string.h>

//#include <conio.h>

#include <sstream>

#include <time.h>





using namespace std;

/*
 
 --------------------------------------------*/

int main()

{
    
    int c = 0;
    
    CvSeq* a = 0;
    
    CvCapture* capture = cvCaptureFromCAM(0);
    
    if(!cvQueryFrame(capture)){ cout<<"Video capture failed, please check the camera."<<endl;}else{cout<<"Video camera capture status: OK"<<endl;};
    
    CvSize sz = cvGetSize(cvQueryFrame( capture));
    
    IplImage* src = cvCreateImage( sz, 8, 3 );
    
    IplImage* hsv_image = cvCreateImage( sz, 8, 3);
    
    IplImage* hsv_mask = cvCreateImage( sz, 8, 1);
    
    IplImage* hsv_edge = cvCreateImage( sz, 8, 1);
    
    
    
    CvScalar  hsv_min = cvScalar(0, 30, 80, 0);
    
    CvScalar  hsv_max = cvScalar(20, 150, 255, 0);
    
    //
    
    CvMemStorage* storage = cvCreateMemStorage(0);
    
    CvMemStorage* areastorage = cvCreateMemStorage(0);
    
    CvMemStorage* minStorage = cvCreateMemStorage(0);
    
    CvMemStorage* dftStorage = cvCreateMemStorage(0);
    
    CvSeq* contours = NULL;
    
    //
    
    cvNamedWindow( "src",1);
    
    //cvNamedWindow( "hsv-msk",1);
    
    //cvNamedWindow( "contour",1);
    
    //////
    
    while( c != 27)
        
    {
        
        IplImage* bg = cvCreateImage( sz, 8, 3);
        
        cvRectangle( bg, cvPoint(0,0), cvPoint(bg->width,bg->height), CV_RGB( 255, 255, 255), -1, 8, 0 );
        
        bg->origin = 1;
        
        for(int b = 0; b< int(bg->width/10); b++)
            
        {
            
            cvLine( bg, cvPoint(b*20, 0), cvPoint(b*20, bg->height), CV_RGB( 200, 200, 200), 1, 8, 0 );
            
            cvLine( bg, cvPoint(0, b*20), cvPoint(bg->width, b*20), CV_RGB( 200, 200, 200), 1, 8, 0 );
            
        }
        
        
        
        src = cvQueryFrame( capture);
        
        cvCvtColor(src, hsv_image, CV_BGR2HSV);
        
        
        
        cvInRangeS (hsv_image, hsv_min, hsv_max, hsv_mask);
        
        cvSmooth( hsv_mask, hsv_mask, CV_MEDIAN, 27, 0, 0, 0 );
        
        cvCanny(hsv_mask, hsv_edge, 1, 3, 5);
        
        
        
        cvFindContours( hsv_mask, storage, &contours, sizeof(CvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cvPoint(0,0) );
        
        CvSeq* contours2 = NULL;
        
        double result = 0, result2 = 0;
        
        while(contours)
            
        {
            
            result = fabs( cvContourArea( contours, CV_WHOLE_SEQ ) );
            
            if ( result > result2) {result2 = result; contours2 = contours;};
            
            contours  =  contours->h_next;
            
        }
        
        if ( contours2 )
            
        {
            
            //cout << "contours2: " << contours2->total << endl;
            
            CvRect rect = cvBoundingRect( contours2, 0 );
            
            cvRectangle( bg, cvPoint(rect.x, rect.y + rect.height), cvPoint(rect.x + rect.width, rect.y), CV_RGB(200, 0, 200), 1, 8, 0 );
            
            //cout << "Ratio: " << rect.width << ", " << rect.height << ", " << (float)rect.width / rect.height << endl;
            
            int checkcxt = cvCheckContourConvexity( contours2 );
            
            //cout << checkcxt <<endl;
            
            CvSeq* hull = cvConvexHull2( contours2, 0, CV_CLOCKWISE, 0 );
            
            CvSeq* defect = cvConvexityDefects( contours2, hull, dftStorage );
            
            if( defect->total >=40 ) {cout << " Closed Palm " << endl;}
            
            else if( defect->total >=30 && defect->total <40 ) {cout << " Open Palm " << endl;}
            
            else{ cout << " Fist " << endl;}
            
            cout << "defet: " << defect->total << endl;
            
            
            
            CvBox2D box = cvMinAreaRect2( contours2, minStorage );
            
            //cout << "box angle: " << (int)box.angle << endl;
            
            cvCircle( bg, cvPoint(box.center.x, box.center.y), 3, CV_RGB(200, 0, 200), 2, 8, 0 );	
            
            cvEllipse( bg, cvPoint(box.center.x, box.center.y), cvSize(box.size.height/2, box.size.width/2), box.angle, 0, 360, CV_RGB(220, 0, 220), 1, 8, 0 );
            
            //cout << "Ratio: " << (float)box.size.width/box.size.height <<endl;
            
        }
        
        //cvShowImage( "hsv-msk", hsv_mask); hsv_mask->origin = 1;
        
        //IplImage* contour = cvCreateImage( sz, 8, 3 );
        
        
        
        cvDrawContours( bg, contours2,  CV_RGB( 0, 200, 0), CV_RGB( 0, 100, 0), 1, 1, 8, cvPoint(0,0));
        
        cvShowImage( "src", src);
        
        //contour->origin = 1; cvShowImage( "contour", contour);
        
        //cvReleaseImage( &contour);
        
        
        
        cvNamedWindow("bg",0); 
        
        cvShowImage("bg",bg); 
        
        cvReleaseImage( &bg);
        
        
        
        
        
        
        
        
        
        c = cvWaitKey( 10);
        
    }
    
    //////
    
    cvReleaseCapture( &capture);
    
    cvDestroyAllWindows();
}
#endif


#include "main.hpp"
////============================================================================
//// Name        : opencv_handdetect.cpp
//// Author      : andol li, andol@andol.info
//// Version     : 0.1
//// Copyright   : 2012
//// Description : using haartraining results to detect the hand gesture of FIST in video stream.
////
////============================================================================
//#include <opencv/cv.h>
//#include <opencv/cxcore.h>
//#include <opencv/highgui.h>
////#include <opencv/objdetect/objdetect.hpp>
//#include <iostream>
//#include <stdio.h>
//
//using namespace cv;
//using namespace std;
//
//const double scale = 1.1;
//
////1.0 api version
//CvMemStorage* storage = 0;
//CvHaarClassifierCascade* cascade = 0;
//void detectAndDraw(IplImage *input_image);
//const char* cascade_name = "/Users/sky/Desktop/gesture/firstHand/firstHand/palm.xml";
//
////define the path to cascade file
//string cascadeName = "palm.xml"; /*ROBUST-fist detection haartraining file*/
//
//int main()
//{
//    //1.0 api version
//    CvCapture *capture =0;
//    IplImage *frame, *frame_copy = 0;
//    cascade = (CvHaarClassifierCascade*)cvLoad( cascade_name, 0, 0, 0 );
//    if( !cascade ){
//        fprintf( stderr, "ERROR: Could not load classifier cascade\n" );
//        return -1;
//    }
//    storage = cvCreateMemStorage(0);
//    capture = cvCaptureFromCAM(0);
//    cvNamedWindow("result", 1);
//    if(capture){
//        for(;;){
//            if(!cvGrabFrame(capture)) break;
//            frame = cvRetrieveFrame( capture);
//            if(!frame) break;
//            if(!frame_copy) frame_copy = cvCreateImage(cvSize(frame->width, frame->height), IPL_DEPTH_8U, frame->nChannels);
//            if(frame->origin == IPL_ORIGIN_TL)
//                cvCopy(frame, frame_copy, 0);
//            else
//                cvFlip(frame, frame_copy, 0);
//            detectAndDraw(frame_copy);
//            if(cvWaitKey(10) >= 0) break;
//        }
//        cvReleaseImage( &frame_copy );
//        cvReleaseCapture( &capture );
//    }
//    
//    return 0;
//}
//
//void detectAndDraw(IplImage *img)
//{
//    double scale = 1.1;
//    IplImage* temp = cvCreateImage( cvSize(img->width/scale,img->height/scale), 8, 3 );
//    CvPoint pt1, pt2;
//    int i;
//    
//    cvClearMemStorage( storage );
//    if(cascade){
//        CvSeq* faces = cvHaarDetectObjects(
//                                           img,
//                                           cascade,
//                                           storage,
//                                           scale, 2, CV_HAAR_DO_CANNY_PRUNING,
//                                           cvSize(24, 24) );
//        for( i = 0; i < (faces ? faces->total : 0); i++ )
//        {
//            CvRect* r = (CvRect*)cvGetSeqElem( faces, i );
//            pt1.x = r->x*scale;
//            pt2.x = (r->x+r->width)*scale;
//            pt1.y = r->y*scale;
//            pt2.y = (r->y+r->height)*scale;
//            cvRectangle( img, pt1, pt2, CV_RGB(200, 0, 0), 1, 8, 0 );
//        }
//    }
//    cvShowImage("result", img);
//    cvReleaseImage( &temp );
//}


//
//// test 2
//#include "opencv/cv.h"
//#include "opencv2/highgui/highgui.hpp"
//#include <iostream>
//#include <stdio.h>
//#include <math.h>
//#include <string.h>
////#include <conio.h>
//
//using namespace std;
//
//IplImage* img = 0;
//
//CvHaarClassifierCascade *cascade;
//CvMemStorage *cstorage;
//CvMemStorage *hstorage;
//
//void detectObjects( IplImage *img );
//int key;
//
//IplImage * shrink(IplImage *input, double scale);
//
//
//int main( int argc, char** argv )
//{
//    CvCapture *capture;
//    IplImage *frame;
//    
//    char *filename = "/Users/sky/Desktop/gesture/firstHand/firstHand/palm.xml";
//    cascade = ( CvHaarClassifierCascade* )cvLoad( "/Users/sky/Desktop/gesture/firstHand/firstHand/palm.xml", 0, 0, 0 );
//    
//    hstorage = cvCreateMemStorage( 0 );
//    cstorage = cvCreateMemStorage( 0 );
//    
//    capture = cvCaptureFromCAM( 0 );
//    
//    cvNamedWindow( "camerawin", 1 );
//    
//    IplImage *src = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0614.JPG");
//    IplImage *desc = shrink(src, 0.2);
//    detectObjects (desc);
//    cvWaitKey(0);
////    while(key!='q') {
////        frame = cvQueryFrame( capture );
////        if( !frame ) break;
////        IplImage *src = frame;
////        IplImage *desc;
////        CvSize sz;
////        double scale = 0.4;
////        if(src)
////        {
////            sz.width = src->width*scale;
////            sz.height = src->height*scale;
////            desc = cvCreateImage(sz,src->depth,src->nChannels);
////            cvResize(src,desc,CV_INTER_CUBIC);
////        }
////        
////        detectObjects (desc);
////        cvReleaseImage(&desc);
////        
////        key = cvWaitKey( 10 );
////    }
//    
//    cvReleaseCapture( &capture );
//    cvDestroyAllWindows();
//    cvReleaseHaarClassifierCascade( &cascade );
//    cvReleaseMemStorage( &cstorage );
//    cvReleaseMemStorage( &hstorage );
//    
//    return 0;
//}
//
//IplImage * shrink(IplImage *input, double scale) {
//    IplImage *desc = NULL;
//    IplImage *src = input;
//    CvSize sz;
//    if(src)
//    {
//        sz.width = src->width*scale;
//        sz.height = src->height*scale;
//        desc = cvCreateImage(sz,src->depth,src->nChannels);
//        cvResize(src,desc,CV_INTER_CUBIC);
//    }
//    return desc;
//}
//
//void detectObjects( IplImage *img )
//{
//    int px;
//    int py;
//    int edge_thresh = 1;
//    IplImage *gray = cvCreateImage( cvSize(img->width,img->height), 8, 1);
//    IplImage *edge = cvCreateImage( cvSize(img->width,img->height), 8, 1);
//    
//    cvCvtColor(img,gray,CV_BGR2GRAY);
//    
//    gray->origin=1;
//    
//    cvThreshold(gray,gray,100,255,CV_THRESH_BINARY);
//    
//    cvSmooth(gray, gray, CV_GAUSSIAN, 11, 11);
//    
//    cvCanny(gray, edge, (float)edge_thresh, (float)edge_thresh*3, 5);
//    
//    CvSeq *hand = cvHaarDetectObjects(img, cascade, hstorage, 1.2, 2, CV_HAAR_DO_CANNY_PRUNING, cvSize(50, 50));
//    
//    CvRect *r = ( CvRect* )cvGetSeqElem( hand, 0 );
//    if (r) {
//    cvRectangle( img,
//                cvPoint( r->x, r->y ),
//                cvPoint( r->x + r->width, r->y + r->height ),
//                CV_RGB( 255, 0, 0 ), 1, 8, 0 );
//    
//    
//    }
//    cvShowImage("camerawin",img);
//    
//    cvReleaseImage(&gray);
//    cvReleaseImage(&edge);
//}



//// test 3
////VERSION: HAND DETECTION 1.0
//
////AUTHOR: ANDOL LI@CW3/18, Live:lab
//
////PROJECT: HAND DETECTION PROTOTYPE
//
////LAST UPDATED: 03/2009
//
//
//#include "opencv/cv.h"
//#include "opencv2/highgui/highgui.hpp"
//#include <iostream>
//#include <stdio.h>
//#include <math.h>
//#include <string.h>
////#include "cxcore.h"
////
////#include "highgui.h"
//
//#include "math.h"
//
//#include <iostream>
//
//#include <stdio.h>
//
//#include <string.h>
//
////#include <conio.h>
//
//#include <sstream>
//
//#include <time.h>
//
//
//
//
//
//using namespace std;
//
///*
// 
// --------------------------------------------*/
//
//int main()
//
//{
//    
//    int c = 0;
//    
//    CvSeq* a = 0;
//    
//    CvCapture* capture = cvCaptureFromCAM(0);
//    
//    if(!cvQueryFrame(capture)){ cout<<"Video capture failed, please check the camera."<<endl;}else{cout<<"Video camera capture status: OK"<<endl;};
//    
//    CvSize sz = cvGetSize(cvQueryFrame( capture));
//    
//    IplImage* src = cvCreateImage( sz, 8, 3 );
//    
//    IplImage* hsv_image = cvCreateImage( sz, 8, 3);
//    
//    IplImage* hsv_mask = cvCreateImage( sz, 8, 1);
//    
//    IplImage* hsv_edge = cvCreateImage( sz, 8, 1);
//    
//    
//    
//    CvScalar  hsv_min = cvScalar(0, 30, 80, 0);
//    
//    CvScalar  hsv_max = cvScalar(20, 150, 255, 0);
//    
//    //
//    
//    CvMemStorage* storage = cvCreateMemStorage(0);
//    
//    CvMemStorage* areastorage = cvCreateMemStorage(0);
//    
//    CvMemStorage* minStorage = cvCreateMemStorage(0);
//    
//    CvMemStorage* dftStorage = cvCreateMemStorage(0);
//    
//    CvSeq* contours = NULL;
//    
//    //
//    
//    cvNamedWindow( "src",1);
//    
//    //cvNamedWindow( "hsv-msk",1);
//    
//    //cvNamedWindow( "contour",1);
//    
//    //////
//    
//    while( c != 27)
//        
//    {
//        
//        IplImage* bg = cvCreateImage( sz, 8, 3);
//        
//        cvRectangle( bg, cvPoint(0,0), cvPoint(bg->width,bg->height), CV_RGB( 255, 255, 255), -1, 8, 0 );
//        
//        bg->origin = 1;
//        
//        for(int b = 0; b< int(bg->width/10); b++)
//            
//        {
//            
//            cvLine( bg, cvPoint(b*20, 0), cvPoint(b*20, bg->height), CV_RGB( 200, 200, 200), 1, 8, 0 );
//            
//            cvLine( bg, cvPoint(0, b*20), cvPoint(bg->width, b*20), CV_RGB( 200, 200, 200), 1, 8, 0 );
//            
//        }
//        
//        
//        
//        src = cvQueryFrame( capture);
//        
//        cvCvtColor(src, hsv_image, CV_BGR2HSV);
//        
//        
//        
//        cvInRangeS (hsv_image, hsv_min, hsv_max, hsv_mask);
//        
//        cvSmooth( hsv_mask, hsv_mask, CV_MEDIAN, 27, 0, 0, 0 );
//        
//        cvCanny(hsv_mask, hsv_edge, 1, 3, 5);
//        
//        
//        
//        cvFindContours( hsv_mask, storage, &contours, sizeof(CvContour), CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE, cvPoint(0,0) );
//        
//        CvSeq* contours2 = NULL;
//        
//        double result = 0, result2 = 0;
//        
//        while(contours)
//            
//        {
//            
//            result = fabs( cvContourArea( contours, CV_WHOLE_SEQ ) );
//            
//            if ( result > result2) {result2 = result; contours2 = contours;};
//            
//            contours  =  contours->h_next;
//            
//        }
//        
//        if ( contours2 )
//            
//        {
//            
//            //cout << "contours2: " << contours2->total << endl;
//            
//            CvRect rect = cvBoundingRect( contours2, 0 );
//            
//            cvRectangle( bg, cvPoint(rect.x, rect.y + rect.height), cvPoint(rect.x + rect.width, rect.y), CV_RGB(200, 0, 200), 1, 8, 0 );
//            
//            //cout << "Ratio: " << rect.width << ", " << rect.height << ", " << (float)rect.width / rect.height << endl;
//            
//            int checkcxt = cvCheckContourConvexity( contours2 );
//            
//            //cout << checkcxt <<endl;
//            
//            CvSeq* hull = cvConvexHull2( contours2, 0, CV_CLOCKWISE, 0 );
//            
//            CvSeq* defect = cvConvexityDefects( contours2, hull, dftStorage );
//            
//            if( defect->total >=40 ) {cout << " Closed Palm " << endl;}
//            
//            else if( defect->total >=30 && defect->total <40 ) {cout << " Open Palm " << endl;}
//            
//            else{ cout << " Fist " << endl;}
//            
//            cout << "defet: " << defect->total << endl;
//            
//            
//            
//            CvBox2D box = cvMinAreaRect2( contours2, minStorage );
//            
//            //cout << "box angle: " << (int)box.angle << endl;
//            
//            cvCircle( bg, cvPoint(box.center.x, box.center.y), 3, CV_RGB(200, 0, 200), 2, 8, 0 );	
//            
//            cvEllipse( bg, cvPoint(box.center.x, box.center.y), cvSize(box.size.height/2, box.size.width/2), box.angle, 0, 360, CV_RGB(220, 0, 220), 1, 8, 0 );
//            
//            //cout << "Ratio: " << (float)box.size.width/box.size.height <<endl;
//            
//        }
//        
//        //cvShowImage( "hsv-msk", hsv_mask); hsv_mask->origin = 1;
//        
//        //IplImage* contour = cvCreateImage( sz, 8, 3 );
//        
//        
//        
//        cvDrawContours( bg, contours2,  CV_RGB( 0, 200, 0), CV_RGB( 0, 100, 0), 1, 1, 8, cvPoint(0,0));
//        
//        cvShowImage( "src", src);
//        
//        //contour->origin = 1; cvShowImage( "contour", contour);
//        
//        //cvReleaseImage( &contour);
//        
//        
//        
//        cvNamedWindow("bg",0); 
//        
//        cvShowImage("bg",bg); 
//        
//        cvReleaseImage( &bg);
//        
//        
//        
//        
//        
//        
//        
//        
//        
//        c = cvWaitKey( 10);
//        
//    }
//    
//    //////
//    
//    cvReleaseCapture( &capture);
//    
//    cvDestroyAllWindows();
//    
//    
//    
//}


//// test4
//#include "opencv/cv.h"
//#include "opencv2/highgui/highgui.hpp"
//#include "opencv/cxcore.h"
//#include <opencv2/legacy/legacy.hpp>
//#include <iostream>
//#include <stdio.h>
//#include <math.h>
//#include <string.h>
//
//IplImage *image = 0 ; //原始图像
//IplImage *image2 = 0 ; //原始图像copy
//
//using namespace std;
//int Thresholdness = 141;
//int ialpha = 20;
//int ibeta=20;
//int igamma=20;
//
//IplImage * shrink(IplImage *input, double scale) {
//    IplImage *desc = NULL;
//    IplImage *src = input;
//    CvSize sz;
//    if(src)
//    {
//        sz.width = src->width*scale;
//        sz.height = src->height*scale;
//        desc = cvCreateImage(sz,src->depth,src->nChannels);
//        cvResize(src,desc,CV_INTER_CUBIC);
//    }
//    return desc;
//}
//
//void onChange(int pos)
//{
//    
//    if(image2) cvReleaseImage(&image2);
//    if(image) cvReleaseImage(&image);
//    
//    image2 = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0614.JPG",1); //显示图片
//    image= cvLoadImage("/Users/sky/Desktop/gesture/IMG_0614.JPG",0);
//    image2 = shrink(image2, 0.2);
//    image = shrink(image, 0.2);
//    cvThreshold(image,image,Thresholdness,255,CV_THRESH_BINARY); //分割域值
//    
//    CvMemStorage* storage = cvCreateMemStorage(0);
//    CvSeq* contours = 0;
//    
//    cvFindContours( image, storage, &contours, sizeof(CvContour), //寻找初始化轮廓
//                   CV_RETR_EXTERNAL , CV_CHAIN_APPROX_SIMPLE );
//    
//    if(!contours) return ;
//    int length = contours->total;
////    if(length<10) return ;
//    CvPoint* point = new CvPoint[length]; //分配轮廓点
//    
//    CvSeqReader reader;
//    CvPoint pt= cvPoint(0,0);;
//    CvSeq *contour2=contours;
//    
//    cvStartReadSeq(contour2, &reader);
//    for (int i = 0; i < length; i++)
//    {
//        CV_READ_SEQ_ELEM(pt, reader);
//        point[i]=pt;
//    }
//    cvReleaseMemStorage(&storage);
//    
//    //显示轮廓曲线
//    for(int i=0;i<length;i++)
//    {
//        int j = (i+1)%length;
//        cvLine( image2, point[i],point[j],CV_RGB( 0, 0, 255 ),1,8,0 );
//    }
//    
//    float alpha=ialpha/100.0f;
//    float beta=ibeta/100.0f;
//    float gamma=igamma/100.0f;
//    
//    CvSize size;
//    size.width=3;
//    size.height=3;
//    CvTermCriteria criteria;
//    criteria.type=CV_TERMCRIT_ITER;
//    criteria.max_iter=1000;
//    criteria.epsilon=0.1;
////    cvSnakeImage( image, point,length,&alpha,&beta,&gamma,0,size,criteria,0 );
//    
//    //显示曲线
//    for(int i=0;i<length;i++)
//    {
//        int j = (i+1)%length;
//        cvLine( image2, point[i],point[j],CV_RGB( 0, 255, 0 ),1,8,0 );
//    }
//    delete []point;
//    
//}
//
//int main(int argc, char* argv[])
//{
//    
//    
//    cvNamedWindow("win1",0);
//    cvCreateTrackbar("Thd", "win1", &Thresholdness, 255, onChange);
//    cvCreateTrackbar("alpha", "win1", &ialpha, 100, onChange);
//    cvCreateTrackbar("beta", "win1", &ibeta, 100, onChange);
//    cvCreateTrackbar("gamma", "win1", &igamma, 100, onChange);
//    cvResizeWindow("win1",300,500);
//    onChange(0);
//    
//    for(;;)
//    {
//        if(cvWaitKey(40)==27) break;
//        cvShowImage("win1",image2);
//    }
//    
//    return 0;
//}

#include "opencv/cv.h"
#include "opencv2/highgui/highgui.hpp"
#include <iostream>
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "opencv2/highgui/highgui.hpp"
#include "opencv2/imgproc/imgproc.hpp"
#include <iostream>
#include <stdio.h>
#include <stdlib.h>

using namespace cv;
using namespace std;

//Mat src; Mat src_gray;
//int thresh = 80;
//int max_thresh = 255;
//RNG rng(12345);
//
///// Function header
//void thresh_callback(int, void* );
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
///** @function main */
//int main( int argc, char** argv )
//{
//    /// Load source image and convert it to gray
////    src = imread( "/Users/sky/Desktop/gesture/IMG_0614.JPG", 1 );
//    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0612.JPG");
//    pImg = shrink(pImg, 0.2);
//    Mat img(pImg,0); // 0是不複製影像，也就是pImg與img的data共用同個記憶體位置，header各自有
//    src = img;
//    /// Convert image to gray and blur it
//    cvtColor( src, src_gray, CV_BGR2GRAY );
//    blur( src_gray, src_gray, Size(3,3) );
//    
//    /// Create Window
//    char* source_window = "Source";
//    namedWindow( source_window, CV_WINDOW_AUTOSIZE );
//    imshow( source_window, src );
//    
//    createTrackbar( " Canny thresh:", "Source", &thresh, max_thresh, thresh_callback );
//    thresh_callback( 0, 0 );
//    
//    waitKey(0);
//    return(0);
//}
//
///** @function thresh_callback */
//void thresh_callback(int, void* )
//{
//    Mat canny_output;
//    vector<vector<Point> > contours;
//    vector<Vec4i> hierarchy;
//    
//    /// Detect edges using canny
//    Canny( src_gray, canny_output, thresh, thresh*2, 3 );
//    printf("th=%d", thresh);
//    /// Find contours
//    findContours( canny_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );
//    
//    /// Draw contours
//    Mat drawing = Mat::zeros( canny_output.size(), CV_8UC3 );
//    for( int i = 0; i< contours.size(); i++ )
//    {
//        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
//        drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, Point() );
//    }
//    
//    /// Show in a window
//    namedWindow( "Contours", CV_WINDOW_AUTOSIZE );
//    imshow( "Contours", drawing );
//}


/// Global Variables
Mat src; Mat hsv;
Mat mask;
int lo = 20; int up = 20;
const char* window_image = "Source image";
/// Function Headers
void Hist_and_Backproj( );
void pickPoint (int event, int x, int y, int, void* );


/** @function main */
//int main( int argc, char** argv )
//{
//    /// Load source image and convert it to gray
////    src = imread( "/Users/sky/Desktop/gesture/IMG_0614.JPG", 1 );
//    IplImage* pImg = cvLoadImage("/Users/sky/Desktop/gesture/IMG_0613.JPG");
//    pImg = shrink(pImg, 0.2);
//    Mat img(pImg,0); // 0是不複製影像，也就是pImg與img的data共用同個記憶體位置，header各自有
//    src = img;
//    
//    /// Transform it to HSV
//    cvtColor( src, hsv, COLOR_BGR2HSV );
//    /// Show the image
//    namedWindow( window_image, WINDOW_AUTOSIZE );
//    imshow( window_image, src );
//    /// Set Trackbars for floodfill thresholds
//    createTrackbar( "Low thresh", window_image, &lo, 255, 0 );
//    createTrackbar( "High thresh", window_image, &up, 255, 0 );
//    /// Set a Mouse Callback
//    setMouseCallback( window_image, pickPoint, 0 );
//    waitKey(0);
//    return 0;
//}
//
///** @function thresh_callback */
//void thresh_callback(int, void* )
//{
//    Mat src_copy = src.clone();
//    Mat threshold_output;
//    vector<vector<Point> > contours;
//    vector<Vec4i> hierarchy;
//    
//    
//    /// Detect edges using canny
//    Canny( src_gray, threshold_output, thresh, thresh*2, 3 );
//    printf("th=%d", thresh);
//    /// Find contours
//    findContours( threshold_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );
//    
//    
////    /// Detect edges using Threshold
////    threshold( src_gray, threshold_output, thresh, 255, THRESH_BINARY );
//    
//    /// Find contours
////    findContours( threshold_output, contours, hierarchy, CV_RETR_TREE, CV_CHAIN_APPROX_SIMPLE, Point(0, 0) );
//    
////    /// Find the convex hull object for each contour
////    vector<vector<Point> >hull( contours.size() );
////    for( int i = 0; i < contours.size(); i++ )
////    {  convexHull( Mat(contours[i]), hull[i], false ); }
////    
////    /// Draw contours + hull results
////    Mat drawing = Mat::zeros( threshold_output.size(), CV_8UC3 );
////    for( int i = 0; i< contours.size(); i++ )
////    {
////        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
////        drawContours( drawing, contours, i, color, 1, 8, vector<Vec4i>(), 0, Point() );
////        drawContours( drawing, hull, i, color, 1, 8, vector<Vec4i>(), 0, Point() );
////    }
////    
////    /// Show in a window
////    namedWindow( "Hull demo", CV_WINDOW_AUTOSIZE );
////    imshow( "Hull demo", drawing );
//    
//    /// Get the moments
//    vector<Moments> mu(contours.size() );
//    for( int i = 0; i < contours.size(); i++ )
//    { mu[i] = moments( contours[i], false ); }
//    
//    ///  Get the mass centers:
//    vector<Point2f> mc( contours.size() );
//    for( int i = 0; i < contours.size(); i++ )
//    { mc[i] = Point2f( mu[i].m10/mu[i].m00 , mu[i].m01/mu[i].m00 ); }
//    
//    /// Draw contours
//    Mat drawing = Mat::zeros( threshold_output.size(), CV_8UC3 );
//    for( int i = 0; i< contours.size(); i++ )
//    {
//        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
//        drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, Point() );
//        circle( drawing, mc[i], 4, color, -1, 8, 0 );
//    }
//    
//    /// Show in a window
//    namedWindow( "Contours", CV_WINDOW_AUTOSIZE );
//    imshow( "Contours", drawing );
//    
//    /// Calculate the area with the moments 00 and compare with the result of the OpenCV function
//    printf("\t Info: Area and Contour Length \n");
//    for( int i = 0; i< contours.size(); i++ )
//    {
//        printf(" * Contour[%d] - Area (M_00) = %.2f - Area OpenCV: %.2f - Length: %.2f \n", i, mu[i].m00, contourArea(contours[i]), arcLength( contours[i], true ) );
//        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
//        drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, Point() );
//        circle( drawing, mc[i], 4, color, -1, 8, 0 );
//    }
//}


/**
 * @function pickPoint
 */
void pickPoint (int event, int x, int y, int, void* )
{
    if( event != EVENT_LBUTTONDOWN )
    { return; }
    // Fill and get the mask
    Point seed = Point( x, y );
    int newMaskVal = 255;
    Scalar newVal = Scalar( 120, 120, 120 );
    int connectivity = 8;
    int flags = connectivity + (newMaskVal << 8 ) + FLOODFILL_FIXED_RANGE + FLOODFILL_MASK_ONLY;
    Mat mask2 = Mat::zeros( src.rows + 2, src.cols + 2, CV_8UC1 );
    floodFill( src, mask2, seed, newVal, 0, Scalar( lo, lo, lo ), Scalar( up, up, up), flags );
    mask = mask2( Range( 1, mask2.rows - 1 ), Range( 1, mask2.cols - 1 ) );
    imshow( "Mask", mask );
    Hist_and_Backproj( );
}
/**
 * @function Hist_and_Backproj
 */
void Hist_and_Backproj( )
{
    MatND hist;
    int h_bins = 30; int s_bins = 32;
    int histSize[] = { h_bins, s_bins };
    float h_range[] = { 0, 179 };
    float s_range[] = { 0, 255 };
    const float* ranges[] = { h_range, s_range };
    int channels[] = { 0, 1 };
    /// Get the Histogram and normalize it
    calcHist( &hsv, 1, channels, mask, hist, 2, histSize, ranges, true, false );
    normalize( hist, hist, 0, 255, NORM_MINMAX, -1, Mat() );
    /// Get Backprojection
    MatND backproj;
    calcBackProject( &hsv, 1, channels, hist, backproj, ranges, 1, true );
    /// Draw the backproj
    imshow( "BackProj", backproj );
}
/**
 * @function Hist_and_Backproj
 * @brief Callback to Trackbar
 */
//void Hist_and_Backproj(int, void* )
//{
//    MatND hist;
//    int histSize = MAX( bins, 2 );
//    float hue_range[] = { 0, 180 };
//    const float* ranges = { hue_range };
//    /// Get the Histogram and normalize it
//    calcHist( &hue, 1, 0, Mat(), hist, 1, &histSize, &ranges, true, false );
//    normalize( hist, hist, 0, 255, NORM_MINMAX, -1, Mat() );
//    /// Get Backprojection
//    MatND backproj;
//    calcBackProject( &hue, 1, 0, hist, backproj, &ranges, 1, true );
//    /// Draw the backproj
//    imshow( "BackProj", backproj );
//    /// Draw the histogram
//    int w = 400; int h = 400;
//    int bin_w = cvRound( (double) w / histSize );
//    Mat histImg = Mat::zeros( w, h, CV_8UC3 );
//    for( int i = 0; i < bins; i ++ )
//    { rectangle( histImg, Point( i*bin_w, h ), Point( (i+1)*bin_w, h - cvRound( hist.at<float>(i)*h/255.0 ) ), Scalar( 0, 0, 255 ), -1 ); }
//    imshow( "Histogram", histImg );
//}



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
#include "main.hpp"

using namespace cv;
using namespace std;

/* Global Variables  */
int fontFace = FONT_HERSHEY_PLAIN;
int square_len;
int avgColor[NSAMPLES][3] ;
int c_lower[NSAMPLES][3];
int c_upper[NSAMPLES][3];
int avgBGR[3];
int nrOfDefects;
int iSinceKFInit;
struct dim{int w; int h;}boundingDim;
VideoWriter out;
Mat edges;
My_ROI roi1, roi2,roi3,roi4,roi5,roi6;
vector <My_ROI> roi;
vector <KalmanFilter> kf;
vector <Mat_<float> > measurement;

/* end global variables */

void init(MyImage *m){
    square_len=20;
    iSinceKFInit=0;
}

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

void printText(Mat src, string text){
    int fontFace = FONT_HERSHEY_PLAIN;
    putText(src,text,Point(src.cols/2, src.rows/10),fontFace, 1.2f,Scalar(200,0,0),2);
}

void waitForPalmCover(MyImage* m){
    m->cap >> m->src;
    flip(m->src,m->src,1);
    roi.push_back(My_ROI(Point(m->src.cols/3, m->src.rows/6),Point(m->src.cols/3+square_len,m->src.rows/6+square_len),m->src));
    roi.push_back(My_ROI(Point(m->src.cols/4, m->src.rows/2),Point(m->src.cols/4+square_len,m->src.rows/2+square_len),m->src));
    roi.push_back(My_ROI(Point(m->src.cols/3, m->src.rows/1.5),Point(m->src.cols/3+square_len,m->src.rows/1.5+square_len),m->src));
    roi.push_back(My_ROI(Point(m->src.cols/2, m->src.rows/2),Point(m->src.cols/2+square_len,m->src.rows/2+square_len),m->src));
    roi.push_back(My_ROI(Point(m->src.cols/2.5, m->src.rows/2.5),Point(m->src.cols/2.5+square_len,m->src.rows/2.5+square_len),m->src));
    roi.push_back(My_ROI(Point(m->src.cols/2, m->src.rows/1.5),Point(m->src.cols/2+square_len,m->src.rows/1.5+square_len),m->src));
    roi.push_back(My_ROI(Point(m->src.cols/2.5, m->src.rows/1.8),Point(m->src.cols/2.5+square_len,m->src.rows/1.8+square_len),m->src));
    
    
    for(int i =0;i<50;i++){
        m->cap >> m->src;
        flip(m->src,m->src,1);
        for(int j=0;j<NSAMPLES;j++){
            roi[j].draw_rectangle(m->src);
        }
        string imgText=string("Cover rectangles with palm");
        printText(m->src,imgText);
        
        if(i==30){
            //	imwrite("./images/waitforpalm1.jpg",m->src);
        }
        
        imshow("img1", m->src);
        out << m->src;
        if(cv::waitKey(30) >= 0) break;
    }
}

int getMedian(vector<int> val){
    int median;
    size_t size = val.size();
    sort(val.begin(), val.end());
    if (size  % 2 == 0)  {
        median = val[size / 2 - 1] ;
    } else{
        median = val[size / 2];
    }
    return median;
}


void getAvgColor(MyImage *m,My_ROI roi,int avg[3]){
    Mat r;
    roi.roi_ptr.copyTo(r);
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

void average(MyImage *m){
    m->cap >> m->src;
    flip(m->src,m->src,1);
    for(int i=0;i<30;i++){
        m->cap >> m->src;
        flip(m->src,m->src,1);
        cvtColor(m->src,m->src,ORIGCOL2COL);
        for(int j=0;j<NSAMPLES;j++){
            getAvgColor(m,roi[j],avgColor[j]);
            roi[j].draw_rectangle(m->src);
        }
        cvtColor(m->src,m->src,COL2ORIGCOL);
        string imgText=string("Finding average color of hand");
        printText(m->src,imgText);
        imshow("img1", m->src);
        if(cv::waitKey(30) >= 0) break;
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
    createTrackbar("lower1","trackbars",&c_lower[0][0],255);
    createTrackbar("lower2","trackbars",&c_lower[0][1],255);
    createTrackbar("lower3","trackbars",&c_lower[0][2],255);
    createTrackbar("upper1","trackbars",&c_upper[0][0],255);
    createTrackbar("upper2","trackbars",&c_upper[0][1],255);
    createTrackbar("upper3","trackbars",&c_upper[0][2],255);
}


void normalizeColors(MyImage * myImage){
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

void produceBinaries(MyImage *m){
    Scalar lowerBound;
    Scalar upperBound;
    Mat foo;
    for(int i=0;i<NSAMPLES;i++){
        normalizeColors(m);
        lowerBound=Scalar( avgColor[i][0] - c_lower[i][0] , avgColor[i][1] - c_lower[i][1], avgColor[i][2] - c_lower[i][2] );
        upperBound=Scalar( avgColor[i][0] + c_upper[i][0] , avgColor[i][1] + c_upper[i][1], avgColor[i][2] + c_upper[i][2] );
        m->bwList.push_back(Mat(m->srcLR.rows,m->srcLR.cols,CV_8U));
        inRange(m->srcLR,lowerBound,upperBound,m->bwList[i]);
    }
    m->bwList[0].copyTo(m->bw);
    for(int i=1;i<NSAMPLES;i++){
        m->bw+=m->bwList[i];
    }
    medianBlur(m->bw, m->bw,7);
}

void initWindows(MyImage m){
    namedWindow("trackbars",CV_WINDOW_KEEPRATIO);
    namedWindow("img1",CV_WINDOW_FULLSCREEN);
}

void showWindows(MyImage m){
    pyrDown(m.bw,m.bw);
    pyrDown(m.bw,m.bw);
    Rect roi( Point( 3*m.src.cols/4,0 ), m.bw.size());
    vector<Mat> channels;
    Mat result;
    for(int i=0;i<3;i++)
        channels.push_back(m.bw);
    merge(channels,result);
    result.copyTo( m.src(roi));
    imshow("img1",m.src);
}

int findBiggestContour(vector<vector<Point> > contours){
    int indexOfBiggestContour = -1;
    int sizeOfBiggestContour = 0;
    for (int i = 0; i < contours.size(); i++){
        if(contours[i].size() > sizeOfBiggestContour){
            sizeOfBiggestContour = contours[i].size();
            indexOfBiggestContour = i;
        }
    }
    return indexOfBiggestContour;
}

void myDrawContours(MyImage *m,HandGesture *hg){
    drawContours(m->src,hg->hullP,hg->cIdx,cv::Scalar(200,0,0),2, 8, vector<Vec4i>(), 0, Point());
    
    
    
    
    rectangle(m->src,hg->bRect.tl(),hg->bRect.br(),Scalar(0,0,200));
    vector<Vec4i>::iterator d=hg->defects[hg->cIdx].begin();
    int fontFace = FONT_HERSHEY_PLAIN;
    
    
    vector<Mat> channels;
    Mat result;
    for(int i=0;i<3;i++)
        channels.push_back(m->bw);
    merge(channels,result);
    //	drawContours(result,hg->contours,hg->cIdx,cv::Scalar(0,200,0),6, 8, vector<Vec4i>(), 0, Point());
    drawContours(result,hg->hullP,hg->cIdx,cv::Scalar(0,0,250),10, 8, vector<Vec4i>(), 0, Point());
    
    
    while( d!=hg->defects[hg->cIdx].end() ) {
   	    Vec4i& v=(*d);
        int startidx=v[0]; Point ptStart(hg->contours[hg->cIdx][startidx] );
        int endidx=v[1]; Point ptEnd(hg->contours[hg->cIdx][endidx] );
        int faridx=v[2]; Point ptFar(hg->contours[hg->cIdx][faridx] );
        float depth = v[3] / 256;
        
         line( m->src, ptStart, ptFar, Scalar(0,255,0), 1 );
         line( m->src, ptEnd, ptFar, Scalar(0,255,0), 1 );
         circle( m->src, ptFar,   4, Scalar(0,255,0), 2 );
         circle( m->src, ptEnd,   4, Scalar(0,0,255), 2 );
         circle( m->src, ptStart,   4, Scalar(255,0,0), 2 );
         /* */
        circle( result, ptFar,   9, Scalar(0,205,0), 5 );
        
        
        d++;
        
    }
    //	imwrite("./images/contour_defects_before_eliminate.jpg",result);
    
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
            hg->eleminateDefects(m);
        }
        bool isHand=hg->detectIfHand();
        hg->printGestureInfo(m->src);
        if(isHand){
            hg->getFingerTips(m);
            hg->drawFingerTips(m);
            myDrawContours(m,hg);
        }
    }
}


int main(){
    MyImage m(0);		
    HandGesture hg;
    init(&m);		
    m.cap >>m.src;
    namedWindow("img1",CV_WINDOW_KEEPRATIO);
    out.open("out.avi", CV_FOURCC('M', 'J', 'P', 'G'), 15, m.src.size(), true);
    waitForPalmCover(&m);
    average(&m);
    destroyWindow("img1");
    initWindows(m);
    initTrackbars();
    for(;;){
        hg.frameNumber++;
        m.cap >> m.src;
        flip(m.src,m.src,1);
        pyrDown(m.src,m.srcLR);
        blur(m.srcLR,m.srcLR,Size(3,3));
        cvtColor(m.srcLR,m.srcLR,ORIGCOL2COL);
        produceBinaries(&m);
        cvtColor(m.srcLR,m.srcLR,COL2ORIGCOL);
        makeContours(&m, &hg);
        hg.getFingerNumber(&m);
        showWindows(m);
        out << m.src;
        //imwrite("./images/final_result.jpg",m.src);
        if(cv::waitKey(30) == char('q')) break;
    }
    destroyAllWindows();
    out.release();
    m.cap.release();
    return 0;
}
