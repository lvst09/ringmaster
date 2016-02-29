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
	int nFaceMinSize; //�ɼ�����С�����ߴ�
	int nStep;        //��������
	int nNumCaThresh; //��������ϲ���ֵ
	int nLayer;       //ʹ�õķ���������
	int cf_flag;      //����ʹ���ļ���������
	int num_expect;   //�����⵽���������ͷ���
	float imageScale; //ͼ������ϵ��
	bool bBiggestFaceOnly; //ֻ������������һ����
	bool bUseSkinColor; //�Ƿ�ʹ����ɫ��Ϣ��ֻ�Բ�ɫͼ��Ч
} ;

DLL_PUBLIC int cvdetectface(const cv::Mat& inmat, std::vector<FaceRect>& faces);
DLL_PUBLIC int cvdetectface(const cv::Mat& inmat, std::vector<FaceRect>& faces, FaceDetectParam param);
#endif // CVDETECTFACE_H