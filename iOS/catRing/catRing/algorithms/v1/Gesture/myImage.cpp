#include "myImage.hpp"
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>

using namespace cv;

MyImage::MyImage() {
}

MyImage::MyImage(int webCamera) {
	cameraSrc=webCamera;
	cap=VideoCapture(webCamera);
}

MyImage::MyImage(IplImage* pImg) {
    cameraSrc=0;
    Mat img(pImg,0); // 0是不複製影像，也就是pImg與img的data共用同個記憶體位置，header各自有
    src = img;
}

MyImage::MyImage(Mat* input) {
    cameraSrc=0;
    src = Mat(*input);
}
