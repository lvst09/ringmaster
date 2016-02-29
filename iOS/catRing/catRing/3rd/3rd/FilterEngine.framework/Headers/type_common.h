#ifndef _TYPE_COMMON_H
#define _TYPE_COMMON_H

#ifdef __cplusplus
extern "C"{
#endif
#include "config.h"
#if _MSC_VER
#define DLL_EXPORT __declspec (dllexport)
#define TEST_DEBUG 1
#elif __GNUC__
#define TEST_DEBUG 0
#define DLL_EXPORT __attribute__ ((visibility ("default")))
#endif

#define  CHANNELS  4
#define  FEATURE_NUM 83
    
#ifdef _MSC_VER // for MSVC
//#define inline  _inline
#define JNIEXPORT
#define JNICALL	
#define LOGD log_printD
#define DEPRECATE_CAST_WARNNIG
#elif defined ANDROID // for gcc on Linux/Apple OS X

#include<android/log.h>
#define DEPRECATE_CAST_WARNNIG (int32_t)
//#define LOG_TAG "debug"
//#define LOGI(fmt, args...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, fmt, ##args)
//#define LOGD(fmt, args...) __android_log_print(ANDROID_LOG_DEBUG, LOG_TAG, fmt, ##args)
//#define LOGE(fmt, args...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, fmt, ##args)
#elif defined (IPHONE4)
#define JNIEnv
#define JNIEXPORT
#define JNICALL	
#define LOGD log_printD
#define DEPRECATE_CAST_WARNNIG
#endif
    
#ifndef TRUE
#define TRUE (1)
#endif
    
#ifndef FALSE 
#define FALSE (0)
#endif

#ifndef NULL
#define NULL 0
#endif

typedef struct _ImageMarker {
	int mark;
	U8 *data;
	int length;
	struct _ImageMarker *next;
} ImageMarker;

typedef struct _Image {
	U8* data;
	unsigned long data_size;
	int width;
	int height;
	int bpp; // bytes of a pixel, bpp == 3 or bpp == 4
	int bytesPerRow; // bytes per line
	int pixelFormat;
	int orientation;
	ImageMarker *marker_list;
} Image;

typedef struct _RECT_T {
	int x0;
	int y0;
	int x1;
	int y1;
} RECT_T;

typedef struct _Rect {
	int x;
	int y;
	int w;
	int h;
} MRect;

typedef union {
	U32 data;
	struct {
		U8 r;
		U8 g;
		U8 b;
		U8 a;
	} rgba;
} Rgba_Type;

typedef struct  
{
	int x;
	int y;
}MPoint;


DLL_EXPORT Image scale_image2(const Image *image, int nw, int nh);
DLL_EXPORT Image* scale_image_ptr(const Image *image, int nw, int nh);

DLL_EXPORT ImageMarker* create_marker();
DLL_EXPORT void free_marker( ImageMarker *marker );
DLL_EXPORT Image* create_empty_image();
DLL_EXPORT Image* create_image(int w, int h, int bpp, int bytesPerRow);
DLL_EXPORT Image create_same_image(const Image *img);
DLL_EXPORT void free_image(Image **image);
DLL_EXPORT Image* create_image_header(int w, int h, int pixelBytes, int bytesPerRow);
DLL_EXPORT void free_image_header(Image **image);
DLL_EXPORT void image_init(Image *image);
DLL_EXPORT void destroy_image(Image *img);
DLL_EXPORT Image crop_image(const Image *img, const MRect *roi);
DLL_EXPORT void image_copy(const Image *source, Image *dst);
DLL_EXPORT Image clone_image(const Image *src);
DLL_EXPORT Image *clone_image2(const Image *src);
DLL_EXPORT void copy_image(Image *dst, const Image *src);
DLL_EXPORT void scale_image(Image *image, int nw, int nh);
DLL_EXPORT int in_range(const MRect *r, int w, int h);
DLL_EXPORT void clear_mrect(MRect *rc);
DLL_EXPORT int is_empty_rect(const MRect *rc);
DLL_EXPORT void inflate_rect(MRect *rc, int ox, int oy);
DLL_EXPORT MRect validate_rect(const MRect *rc, const MRect *boundary);
DLL_EXPORT MRect intersect(const MRect *r1, const MRect *r2);
DLL_EXPORT int rect_contains_rect(const MRect *r1, const MRect *r2);
DLL_EXPORT MRect scale_rect(const MRect *r1, const float ratio);
DLL_EXPORT MRect scale_rect_xy(const MRect *r1, const float ratiox, const float ratioy);
DLL_EXPORT Image create_image2(int w, int h, int bpp);
Image load_raw_to_image(const char *fileName, int w, int h, int bpp);
DLL_EXPORT Image* load_image_from_raw(const char *fileName, int w, int h, int bpp);
DLL_EXPORT Image convert_image_gray(Image input);
DLL_EXPORT Image* buildPyramid(Image *srcImage, int step);
DLL_EXPORT void clear_image(Image *image, U8 clr);
void save_image_to_raw(const char *fileName, const Image *img);
DLL_EXPORT Image crop_image_with_angle(const Image *img, const MRect *roi, double agl);
DLL_EXPORT Image clone_image_roi(const Image *img, const MRect *roi);
DLL_EXPORT void copy_image_roi(const Image *src, Image *dst, MRect *srcRoi, MRect *dstRoi);
#ifdef __cplusplus
}
#endif

#endif
