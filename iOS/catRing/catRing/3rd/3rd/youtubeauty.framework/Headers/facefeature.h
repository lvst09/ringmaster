#ifndef FACEFEATURE_H
#define FACEFEATURE_H

#include <string>
#include <opencv2/core/core.hpp>
#include "facealignment_export.h"

// extract face features
// mat, the image, 8bit depth, 4 channels, RGBA order
//             or, 8bit depth, 3 channels, RGB order
//             or, 8bit depth, 1 channel, grayscale(preferred)
// facerect, the rectangle of face area
// poly, the polygen of face area
// leftEye, left eye position
// rightEye, right eye position
// midMouth, mouth center position
// feature, the extracted feature vector
// return 0 if success
FACEALIGNMENT_EXPORT int face_feature(const cv::Mat& mat, const cv::Rect& facerect, const std::vector<cv::Point>& poly, cv::Point& leftEye, cv::Point& rightEye, cv::Point& midMouth, std::string& feature);

// extract face features
// mat, the image, 8bit depth, 4 channels, RGBA order
//             or, 8bit depth, 3 channels, RGB order
//             or, 8bit depth, 1 channel, grayscale(preferred)
// leftEye, left eye position
// rightEye, right eye position
// midMouth, mouth center position
// feature, the extracted feature vector
// return 0 if success
FACEALIGNMENT_EXPORT int face_feature(const cv::Mat& mat, cv::Point& leftEye, cv::Point& rightEye, cv::Point& midMouth, std::string& feature);

#endif // FACEFEATURE_H
