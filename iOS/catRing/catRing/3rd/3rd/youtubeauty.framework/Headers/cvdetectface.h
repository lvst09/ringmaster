#ifndef CVDETECTFACE_H
#define CVDETECTFACE_H

#include <vector>
#include <opencv2/core/core.hpp>
#ifndef FACERECT_STRUCT
#define FACERECT_STRUCT
struct FaceRect{
	int x, y, w, h;
	float confidence;
};
#endif

#if _WIN32
#define DLL_PUBLIC __declspec (dllexport)
#elif __GNUC__
#define DLL_PUBLIC __attribute__ ((visibility ("default")))
#endif

enum classifier_flag
{
	FRONT = 1,
	LEFT_TILT_FRONT = 1 << 1,
	RIGHT_TILT_FRONT = 1 << 2,
	LEFT_HALF_PROFILE = 1 << 3,
	RIGHT_HALF_PROFILE = 1 << 4
	//to be continue
};
struct DLL_PUBLIC FaceDetectParam
{
	FaceDetectParam();
	int nFaceMinSize; //可检测的最小人脸尺寸
	int nStep;        //搜索步长
	int nNumCaThresh; //人脸后处理合并阈值
	int nLayer;       //使用的分类器层数
	int cf_flag;      //定义使用哪几个分类器
	int num_expect;   //定义检测到几个人脸就返回
	float imageScale; //图像缩放系数
	bool bBiggestFaceOnly; //只检测出最大面积的一张脸
	bool bUseSkinColor; //是否使用颜色信息，只对彩色图有效
} ;

DLL_PUBLIC int cvdetectface(const cv::Mat& inmat, std::vector<FaceRect>& faces);
DLL_PUBLIC int cvdetectface(const cv::Mat& inmat, std::vector<FaceRect>& faces, FaceDetectParam param);
#endif // CVDETECTFACE_H