#ifndef _HAND_GESTURE_
#define _HAND_GESTURE_ 

#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include <vector>
#include <string>
#include "mymain.hpp"
#include "myImage.hpp"
#include <opencv2.framework/Headers/core/core.hpp>
using namespace cv;
using namespace std;

class HandGesture{
	public:
//		MyImage m;
		HandGesture();
		vector<vector<Point2i> > contours;
		vector<vector<int> >hullI;
		vector<vector<Point2i> >hullP;
		vector<vector<Vec4i> > defects;
    
    
        //特征点
        int index;
        vector <Point2i> mediusFinger;
        vector <double> rotationAngle;
        vector <Point2i> ringPosition;
    
        // ouput 手指位置
		vector <Point2i> fingerTips;
    
		Rect_<int> rect;
		void printGestureInfo();
		int cIdx;
		int frameNumber;
		int mostFrequentFingerNumber;
		int nrOfDefects;
		Rect_<int> bRect;
		double bRect_width;
		double bRect_height;
		bool isHand;
		bool detectIfHand();
		void initVectors();
		void getFingerNumber(Mat &src);
		void eleminateDefects();
		void getFingerTips(int rowLen);
    
        void addNumberToImg(Mat &src); // please call after getFinggerTips.
		void drawFingerTips(Mat &src);
	private:
		string bool2string(bool tf);
		int fontFace;
		int prevNrFingerTips;
		void checkForOneFinger(int rowLen);
		float getAngle(Point2i s,Point2i f,Point2i e);
		vector<int> fingerNumbers;
		void analyzeContours();
		string intToString(int number);
		void computeFingerNumber();
		void drawNewNumber(MyImage *m);
//		void addNumberToImg(MyImage *m);    
		vector<int> numbers2Display;
		void addFingerNumberToVector();
		Scalar numberColor;
		int nrNoFinger;
		float distanceP2P(Point2i a,Point2i b);
		void removeRedundantEndPoints(vector<Vec4i> newDefects);
		void removeRedundantFingerTips();
};




#endif
