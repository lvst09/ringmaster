#ifndef CVATTRIBUTEREC_H
#define CVATTRIBUTEREC_H

#include <opencv2/core/core.hpp>

class Attribute_RecM;
class cv_AttributeRecM
{
public:
    ~cv_AttributeRecM();

    // some initialization, somehow slow
    int init();

    // detect gender
    // bigImage, the image, 8bit depth, 1 channel, grayscale
    // leftEye, the left eye
    // rightEye, the right eye
    // gender, gender probablity
    // gender=0 -> female 100%
    // gender=50 -> ???
    // gender=100 -> male 100%
    // return 0 if success
    int cvdetectgender(const cv::Mat& bigImage, const cv::Point& leftEye,const cv::Point& rightEye, int& gender);

    // detect expression
    // bigImage, the image, 8bit depth, 1 channel, grayscale
    // leftEye, the left eye
    // rightEye, the right eye
    // expression, expression probablity
    // expression=0 -> normal
    // expression=50 -> smile
    // expression=100 -> laugh
    // return 0 if success
    int cvdetectexpression(const cv::Mat& bigImage, const cv::Point& leftEye,const cv::Point& rightEye, int& expression);
	
	/* Testing */
	 // detect age
    // bigImage, the image, 8bit depth, 1 channel, grayscale
    // leftEye, the left eye
    // rightEye, the right eye
    // age ,age region
    // age=0 -> 0-1
	// age=1 -> 2-3
	// age=2 -> 4-11
	// age=3 -> 12-16
	// age=4 -> 17-40
	// age=5 -> 41-60
	// age=6 -> 60+
    // return 0 if success
	int cvdetectage(const cv::Mat& bigImage, const cv::Point& leftEye,const cv::Point& rightEye, int& age);


	
private:

    Attribute_RecM* genderRec;
	Attribute_RecM* genderYoungRec;
	Attribute_RecM* ageC2Rec;
	Attribute_RecM* expressionRec;
	Attribute_RecM* ageRec;



	
	
};

#endif // CVATTRIBUTEREC_H
