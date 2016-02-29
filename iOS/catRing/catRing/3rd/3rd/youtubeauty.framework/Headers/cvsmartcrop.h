#ifndef CVSMARTCROP_H
#define CVSMARTCROP_H

#include <opencv2/core/core.hpp>

// smart crop
// mat, the image, 8bit depth, 4 channels, RGBA order
//             or, 8bit depth, 3 channels, RGB order
//             or, 8bit depth, 1 channel, grayscale(preferred)
// roi, the position and size of cropped area
// facerects, array of face rectangles, can be empty
// return 0
int cvsmartcrop(const cv::Mat& mat, cv::Rect& roi, const std::vector<cv::Rect>& facerects);

// smart crop with given size
// mat, the image, 8bit depth, 4 channels, RGBA order
//             or, 8bit depth, 3 channels, RGB order
//             or, 8bit depth, 1 channel, grayscale(preferred)
// topleft, the top left point of cropped area
// size, the size of cropped area
// facerects, array of face rectangles, can be empty
// return 0
int cvsmartcrop(const cv::Mat& mat, cv::Point& topleft, const cv::Size& size, const std::vector<cv::Rect>& facerects);

#endif // CVSMARTCROP_H
