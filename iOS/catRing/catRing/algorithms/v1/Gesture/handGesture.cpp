#include "handGesture.hpp"
#include <opencv2/imgproc/imgproc.hpp>
#include <opencv2/opencv.hpp>
#include <opencv2/highgui/highgui.hpp>
#include <stdio.h>
#include <stdlib.h>
#include <iostream>
#include <string>
#include "CommonCPPMath.h"
#include "PreHeader.h"

using namespace cv;
using namespace std;

HandGesture::HandGesture(){
	frameNumber=0;
	nrNoFinger=0;
	fontFace = FONT_HERSHEY_PLAIN;
    
    ringAngle = 0;
    ringCenter = Point2i(0,0);
    rotationAngle.push_back(0);
    rotationAngle.push_back(0);
    rotationAngle.push_back(0);
}

void HandGesture::initVectors(){
	hullI=vector<vector<int> >(contours.size());
	hullP=vector<vector<Point> >(contours.size());
	defects=vector<vector<Vec4i> > (contours.size());	
}

void HandGesture::analyzeContours(){
	bRect_height=bRect.height;
	bRect_width=bRect.width;
}

string HandGesture::bool2string(bool tf){
	if(tf)
		return "true";
	else
		return "false";
}

string HandGesture::intToString(int number){
		stringstream ss;
		ss << number;
		string str = ss.str();
		return str;
}

void HandGesture::printGestureInfo(){
//	int fontFace1 = FONT_HERSHEY_PLAIN;
//	Scalar fColor(245,200,200);
//	int xpos=src.cols/1.5;
//	int ypos=src.rows/1.6;
//	float fontSize=0.7f;
//	int lineChange=14;
	string info= "Figure info:";
//	putText(src,info,Point(ypos,xpos),fontFace1,fontSize,fColor);
    cout << info << endl;
    
//	xpos+=lineChange;
	info=string("Number of defects: ") + string(intToString(nrOfDefects)) ;
//	putText(src,info,Point(ypos,xpos),fontFace1,fontSize  ,fColor);
    cout << info << endl;
    
//	xpos+=lineChange;
	info=string("bounding box height, width ") + string(intToString(bRect_height)) + string(" , ") +  string(intToString(bRect_width)) ;
//	putText(src,info,Point(ypos,xpos),fontFace1,fontSize ,fColor);
    cout << info << endl;
    
//	xpos+=lineChange;
	info=string("Is hand: ") + string(bool2string(isHand));
//	putText(src,info,Point(ypos,xpos),fontFace1,fontSize  ,fColor);
    cout << info << endl;
}

bool HandGesture::detectIfHand(){
	analyzeContours();
	double h = bRect_height; 
	double w = bRect_width;
	isHand=true;
	if(fingerTips.size() > 5 || fingerTips.size() < 4){
		isHand=false;
	}else if( h==0 || w == 0){
		isHand=false;
	}else if(h/w > 4 || w/h >4){
		isHand=false;	
	}else if(bRect.x<20){
//		isHand=false;	
    }else if(fingerBases.size()<3) {
        isHand = false;
    }
    if (fingerLengths.size() < 3) {
        isHand = false;
        return isHand;
    }
    {
//        vector<double>::iterator d = fingerLengths.begin();
        double midFingerLength = fingerLengths[0];
        double fourthFingerLength = fingerLengths[1];
        double fifthFingerLength = fingerLengths[2];
        double secondFingerLength = fingerLengths[fingerLengths.size() - 1];
        
        double max = MAX(midFingerLength, fourthFingerLength);
        max = MAX(max, fifthFingerLength);
        max = MAX(max, secondFingerLength);
        
        if(abs (max - midFingerLength) > 0.01 && abs (max - fourthFingerLength) > 0.01)
        {
            isHand = false;
        }
        
        double min = MIN(midFingerLength, fourthFingerLength);
        min = MIN(min, fifthFingerLength);
        min = MIN(min, secondFingerLength);
        if(abs(min - fifthFingerLength) > 0.01)
        {
            isHand = false;
        }
    }
    
    //指根间距过大
    {
        Point baseMidFinger = fingerBases[0];
        Point baseFourthFinger = fingerBases[1];
        Point baseSecondFinger = fingerBases[fingerBases.size()-1];
        double distance01 = distanceOfPoint(baseMidFinger, baseFourthFinger);
        double distance02 = distanceOfPoint(baseMidFinger, baseSecondFinger);
        if(distance01 > 250 || distance02 > 250)
        {
            isHand = false;
        }
        else {
        }
        
    }
    
    vector<Vec4i>::iterator d=defects[cIdx].begin();
//    while( d!=defects[cIdx].end() )
    {
        {
            Vec4i& v=(*d);
            int startidx=v[0];
            Point ptStart(contours[cIdx][startidx] );
            
            int endidx=v[1];
            Point ptEnd(contours[cIdx][endidx] );
            int faridx=v[2];
            Point ptFar(contours[cIdx][faridx] );

            Point vecSF = vectorBetweenPoints(ptStart, ptFar);
            Point vecEF = vectorBetweenPoints(ptEnd, ptFar);
            
            double crossAngle = vectorCrossAngle(vecSF,vecEF);
            
            //如果中指开角太大则去掉
            if(crossAngle > M_PI / 4)
            {
 
                isHand = false;
            }
        }
    }

	return isHand;
}

float HandGesture::distanceP2P(Point a, Point b){
	float d= sqrt(fabs( pow(a.x-b.x,2) + pow(a.y-b.y,2) )) ;
	return d;
}

// remove fingertips that are too close to
// eachother
void HandGesture::removeRedundantFingerTips(){
	vector<Point> newFingers;
	for(int i=0;i<fingerTips.size();i++){
		for(int j=i;j<fingerTips.size();j++){
			if(distanceP2P(fingerTips[i],fingerTips[j])<10 && i!=j){
			}else{
				newFingers.push_back(fingerTips[i]);	
				break;
			}	
		}	
	}
	fingerTips.swap(newFingers);
}

void HandGesture::computeFingerNumber(){
	std::sort(fingerNumbers.begin(), fingerNumbers.end());
	int frequentNr;	
	int thisNumberFreq=1;
	int highestFreq=1;
	frequentNr=fingerNumbers[0];
	for(int i=1;i<fingerNumbers.size(); i++){
		if(fingerNumbers[i-1]!=fingerNumbers[i]){
			if(thisNumberFreq>highestFreq){
				frequentNr=fingerNumbers[i-1];	
				highestFreq=thisNumberFreq;
			}
			thisNumberFreq=0;	
		}
		thisNumberFreq++;	
	}
	if(thisNumberFreq>highestFreq){
		frequentNr=fingerNumbers[fingerNumbers.size()-1];	
	}
	mostFrequentFingerNumber=frequentNr;	
}

void HandGesture::addFingerNumberToVector(){
	int i= (int) fingerTips.size();
	fingerNumbers.push_back(i);
}

// add the calculated number of fingers to image m->src
void HandGesture::addNumberToImg(Mat &src) {
	int xPos=10;
	int yPos=10;
	int offset=30;
	float fontSize=1.5f;
	int fontFace1 = FONT_HERSHEY_PLAIN;
	for(int i=0;i<numbers2Display.size();i++){
		rectangle(src,Point(xPos,yPos),Point(xPos+offset,yPos+offset),numberColor, 2);
		putText(src, intToString(numbers2Display[i]),Point(xPos+7,yPos+offset-3),fontFace1,fontSize,numberColor);
		xPos+=40;
		if(xPos>(src.cols-src.cols/3.2)){
			yPos+=40;
			xPos=10;
		}
	}
}

// calculate most frequent numbers of fingers 
// over 20 frames
// 并且将结果画到video上去
void HandGesture::getFingerNumber(Mat &src) {
    
	removeRedundantFingerTips();
	if(bRect.height > src.rows/2 && nrNoFinger>12 && isHand ){
		numberColor=Scalar(0,200,0);
		addFingerNumberToVector();
		if(frameNumber>12){
			nrNoFinger=0;
			frameNumber=0;	
			computeFingerNumber();	
			numbers2Display.push_back(mostFrequentFingerNumber);
			fingerNumbers.clear();
		}else{
			frameNumber++;
		}
	}else{
		nrNoFinger++;
		numberColor=Scalar(200,200,200);
	}

//	addNumberToImg(src);
}

float HandGesture::getAngle(Point s, Point f, Point e){
	float l1 = distanceP2P(f,s);
	float l2 = distanceP2P(f,e);
	float dot=(s.x-f.x)*(e.x-f.x) + (s.y-f.y)*(e.y-f.y);
	float angle = acos(dot/(l1*l2));
	angle=angle*180/PI;
	return angle;
}

void HandGesture::eleminateDefects(){
	int tolerance =  bRect_height/5;
	float angleTol=95;
	vector<Vec4i> newDefects;
	int startidx, endidx, faridx;
	vector<Vec4i>::iterator d=defects[cIdx].begin();
	while( d!=defects[cIdx].end() ) {
   	    Vec4i& v=(*d);
	    startidx=v[0]; Point ptStart(contours[cIdx][startidx] );
   		endidx=v[1]; Point ptEnd(contours[cIdx][endidx] );
  	    faridx=v[2]; Point ptFar(contours[cIdx][faridx] );
		if(distanceP2P(ptStart, ptFar) > tolerance && distanceP2P(ptEnd, ptFar) > tolerance && getAngle(ptStart, ptFar, ptEnd  ) < angleTol ){
			if( ptEnd.y > (bRect.y + bRect.height -bRect.height/4 ) ){
			}else if( ptStart.y > (bRect.y + bRect.height -bRect.height/4 ) ){
			}else {
				newDefects.push_back(v);		
			}
		}	
		d++;
	}
	nrOfDefects = (int) newDefects.size();
	defects[cIdx].swap(newDefects);
	removeRedundantEndPoints(defects[cIdx]);
}

//Point2i middlePoint1(Point2i p1, Point2i p2)
//{
//    return Point((p1.x+p2.x)/2, (p1.y+p2.y)/2 );
//}
//double distanceOfPoint1(Point2i p1, Point2i p2)
//{
//    return  sqrt((pow((p1.x - p2.x),2) +  pow((p1.y - p2.y),2)));
//}

//Point middlePoint(Point p1, Point p2)
//{
//    return Point((p1.x+p2.x)/2, (p1.y+p2.y)/2 );
//}
//double distanceOfPoint(Point p1, Point p2)
//{
//    return  sqrt((pow((p1.x - p2.x),2) +  pow((p1.y - p2.y),2)));
//}
//
Point vectorBetweenPoints1(Point p1, Point p2)
{
    return Point((p1.x - p2.x) ,(p1.y - p2.y));
}

//double vectorAngle(Point vec)
//{
//    if (vec.x==0) {
//        vec.x+=1;
//    }
//    
//    double b =  atan(vec.y/vec.x);
//    if(vec.x <= 0 && vec.y>0)
//        b += M_PI;
//    else if(vec.x <0 && vec.y<=0)
//        b += M_PI ;
//    if (vec.y<0 && vec.x>=0) {
//        b += M_PI * 2;
//    }
//    return b;
//}

double vectorCrossAngle1(Point p1, Point p2)
{
    double dotProduct =  ( p1.x * p2.x + p1.y * p2.y );
    
    double m = sqrt(p1.x*p1.x + p1.y*p1.y) * sqrt(p2.x*p2.x + p2.y*p2.y);
    
    return acos(dotProduct/m);
}

//Point vectorMultiply(Point vector ,float multi)
//{
//    return Point(vector.x * multi , vector.y * multi);
//}
//
//Point pointMove(Point point ,Point vector)
//{
//    return Point(vector.x + point.x , vector.y + point.y);
//}

void HandGesture::removeRedundantFinger()
{
        int count = (int)defects[cIdx].size();
 
            vector<Vec4i>::iterator d=defects[cIdx].begin();//从中指开始
            int i = 0;
            while( d!=defects[cIdx].end() )
            {
                if(i == 2)
                {
                    Vec4i& v=(*d);
                    int startidx=v[0];
                    Point ptStart(contours[cIdx][startidx] );
                    
                    int endidx=v[1];
                    Point ptEnd(contours[cIdx][endidx] );
                    int faridx=v[2];
                    Point ptFar(contours[cIdx][faridx] );
                    
                    Vec4i& v_prevprev=(*(d-2));
                    int startidx_prevprev=v_prevprev[0];
                    Point ptStart_prevprev(contours[cIdx][startidx_prevprev] );
                    
                    int endidx_prevprev=v_prevprev[1];
                    Point ptEnd_prevprev(contours[cIdx][endidx_prevprev] );
                    int faridx_prevprev=v_prevprev[2];
                    Point ptFar_prevprev(contours[cIdx][faridx_prevprev] );
   
                    Vec4i& v_prev=(*(d-1));
                    int startidx_prev=v_prev[0];
                    Point ptStart_prev(contours[cIdx][startidx_prev] );
                    
                    int endidx_prev=v_prev[1];
                    Point ptEnd_prev(contours[cIdx][endidx_prev] );
                    int faridx_prev=v_prev[2];
                    Point ptFar_prev(contours[cIdx][faridx_prev] );
 
                    if((ptFar.y - ptFar_prev.y) * (ptFar_prev.y - ptFar_prevprev.y)>0)
                    {
 
                        
                        //Point ptMid = middlePoint1(ptStart, ptEnd);
                        if (d!=defects[cIdx].end())
                        {
                            vector<Vec4i>::iterator e = d+1;
                            Vec4i& t = (*e);
                            //                    int endidx=t[1];
                            int startidx = t[0];
                            if(startidx < contours[cIdx].size())
                            {
//                                contours[cIdx][startidx] = ptEnd;
 
                                d = defects[cIdx].erase(d++);
                                continue;
                            }
                        }
                        
                    }
                }
                d++;
                i++;
                
            count = (int)defects[cIdx].size();
     }
}

void HandGesture::reduceDefect()
{

    int count = (int)defects[cIdx].size();
    int times = 0;
    int erased = 1;
    while (count > 4 && erased>0)
    {
        times ++ ;
        
        erased = 0;
        vector<Vec4i>::iterator d=defects[cIdx].begin();//从中指开始
//      int count = (int)defects[cIdx].size();
        //第一次滤掉杂波，之后认为中指和无名指是正确的
        if (times>1)
        {
            d++ ;
            d++;
//            d++;
        }
        dprintf("defects cout before reduce : %d \n", count);
        int i = 0;
        while( d!=defects[cIdx].end() )
        {
            {
                Vec4i& v=(*d);
                int startidx=v[0];
                Point ptStart(contours[cIdx][startidx] );
                
                int endidx=v[1];
                Point ptEnd(contours[cIdx][endidx] );
                int faridx=v[2];
                Point ptFar(contours[cIdx][faridx] );
                
                double disSF = distanceOfPoint(ptStart, ptFar);
                double disEF = distanceOfPoint(ptEnd, ptFar);
                
                Point vecSF = vectorBetweenPoints1(ptStart, ptFar);
                Point vecEF = vectorBetweenPoints1(ptEnd, ptFar);
                
                double crossAngle = vectorCrossAngle1(vecSF,vecEF);
                double scale = 1.f;
#if kUseLowResolution
                scale = 568.f / 1280.f;
#endif
                
                //如果手指长度太短太长 或开角太大 就滤掉
                if(disSF < 120 * scale || disSF > 500 * scale ||  disEF < 120 * scale || disEF > 500 * scale ||crossAngle > M_PI / 2)
                {
                    
                    if(disEF> 220 * scale && disEF * scale < 500 && crossAngle < M_PI / 2 )
                    {
                        d++;
                        i++;
                        continue;//有可能是大拇指
                    }
                    
                    //Point ptMid = middlePoint1(ptStart, ptEnd);
                    if (d!=defects[cIdx].end())
                    {
                        vector<Vec4i>::iterator e = d+1;
                        Vec4i& t = (*e);
                        //                    int endidx=t[1];
                        int startidx = t[0];
                        if(startidx < contours[cIdx].size())
                        {
                            contours[cIdx][startidx] = ptEnd;
                            //
                            //             e = d+1;
                            //             t = (*e);
                            //             int startidx=t[0];
                            //             contours[cIdx][startidx] = ptMid;
                            //
                            erased ++;
                            d = defects[cIdx].erase(d++);
                            continue;
                        }
                    }

                }
            }
            d++;
            i++;
            
        }
        count = (int)defects[cIdx].size();
 
    }
    
    removeRedundantFinger();
    dprintf("defects cout after reduce : %d \n", (int)defects[cIdx].size());
}


// remove endpoint of convexity defects if they are at the same fingertip
void HandGesture::removeRedundantEndPoints(vector<Vec4i> newDefects){
	Vec4i temp;
//	float avgX, avgY;
	float tolerance=bRect_width/6;
    int startidx, endidx;//, faridx;
	int startidx2, endidx2;
	for(int i=0;i<newDefects.size();i++){
		for(int j=i;j<newDefects.size();j++){
	    	startidx=newDefects[i][0]; Point ptStart(contours[cIdx][startidx] );
	   		endidx=newDefects[i][1]; Point ptEnd(contours[cIdx][endidx] );
	    	startidx2=newDefects[j][0]; Point ptStart2(contours[cIdx][startidx2] );
	   		endidx2=newDefects[j][1]; Point ptEnd2(contours[cIdx][endidx2] );
			if(distanceP2P(ptStart,ptEnd2) < tolerance ){
				contours[cIdx][startidx]=ptEnd2;
				break;
			}if(distanceP2P(ptEnd,ptStart2) < tolerance ){
				contours[cIdx][startidx2]=ptEnd;
			}
		}
	}
}

// convexity defects does not check for one finger
// so another method has to check when there are no
// convexity defects
void HandGesture::checkForOneFinger(int rowLen){
	int yTol=bRect.height/6;
	Point highestP;
	highestP.y=rowLen;
	vector<Point>::iterator d=contours[cIdx].begin();
	while( d!=contours[cIdx].end() ) {
   	    Point v=(*d);
		if(v.y<highestP.y){
			highestP=v;
			cout<<highestP.y<<endl;
		}
		d++;	
	}int n=0;
	d=hullP[cIdx].begin();
	while( d!=hullP[cIdx].end() ) {
   	    Point v=(*d);
			cout<<"x " << v.x << " y "<<  v.y << " highestpY " << highestP.y<< "ytol "<<yTol<<endl;
		if(v.y<highestP.y+yTol && v.y!=highestP.y && v.x!=highestP.x){
			n++;
		}
		d++;	
	}if(n==0){
		fingerTips.push_back(highestP);
	}
}

void HandGesture::drawFingerTips(Mat &src){
	Point p;
	int k = (int)fingerTips.size();
	for(int i=0;i<k;i++){
		p=fingerTips[i];
		putText(src,intToString(i),p-Point(0,30),fontFace, 1.2f,Scalar(200,200,200),2);
        
        double val =(double) i / (double)k * 255.f;
        Scalar scalar = Scalar(val,val,val);
   		circle(src,p,   15,scalar, 4 );
   	 }
    
    k = (int)fingerBases.size();
    for(int i=0;i<k;i++){
        p=fingerBases[i];
        putText(src,intToString(i),p-Point(0,30),fontFace, 1.2f,Scalar(200,200,200),2);
        
        double val =(double) i / (double)k * 255.f;
        Scalar scalar = Scalar(val,val,val);
        circle(src,p,   15,scalar, 4 );
    }
    
}

void HandGesture::getFingerTips(int rowLen){
	fingerTips.clear();
    fingerBases.clear();
	int i=0;
	vector<Vec4i>::iterator d=defects[cIdx].begin();
	while( d!=defects[cIdx].end() ) {
   	    Vec4i& v=(*d);
	    int startidx=v[0]; Point ptStart(contours[cIdx][startidx] );
   		int endidx=v[1]; Point ptEnd(contours[cIdx][endidx] );
  	    int faridx=v[2]; Point ptFar(contours[cIdx][faridx] );
//		if(i==0){
			fingerTips.push_back(ptStart);
            fingerBases.push_back(ptFar);
//			i++;
//		}
//		fingerTips.push_back(ptEnd);
        double dist = distanceOfPoint(ptStart, ptFar);
        fingerLengths.push_back(dist);
        if(i==1){
            fingerTips.push_back(ptEnd);
            dist = distanceOfPoint(ptEnd, ptFar);
            fingerLengths.push_back(dist);
        }
		d++;
		i++;
   	}
	if(fingerTips.size()==0){
		checkForOneFinger(rowLen);
	}
}
