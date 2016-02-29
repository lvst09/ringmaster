#define TESTST
#ifdef TESTST
#include <stdlib.h>
#include <math.h>
#include <memory.h>
#include "type_common.h"

#ifdef __cplusplus
extern "C"
{
#endif

#ifndef CLAMP
#define CLAMP(x,l,u) ((x)<(l)?(l):((x)>(u)?(u):(x)))
#endif
#ifndef MAX
#define MAX(a,b)        (((a) > (b)) ? (a) : (b))
#endif
#ifndef MIN
#define MIN(a,b)        (((a) < (b)) ? (a) : (b))
#endif
#ifndef ABS
#define ABS(a)			((a) < 0 ? -(a) : (a))
#endif

    
    typedef struct image_float
    {
        float* data;
        int width;
        int height;
    }Image_Float;


Image_Float* Image_Convolve(Image_Float* img_in, float* kernel, int kernel_length);

Image_Float* Transpose_Image(Image_Float* img_in);

Image_Float* Remove_Image_Border(Image_Float* img_in, int left_width, int right_width);

Image_Float* Image_Up_Scale_Inner_2_3(Image_Float* img_in); // for 3/2 upscale

Image_Float* Image_Down_Scale_Inner_2_3(Image_Float* img_in); // for 2/3 downscale

Image_Float* Image_High_Freq_2_3(Image_Float* img_in);


Image_Float* Image_Up_Scale_Inner_3_4(Image_Float* img_in); // for 3/2 upscale

Image_Float* Image_Down_Scale_Inner_3_4(Image_Float* img_in); // for 2/3 downscale

Image_Float* Image_High_Freq_3_4(Image_Float* img_in);

void Add_Image_To_Pool(Image_Float* img);

Image_Float* Convolve_Herizontal_Upscale_3_4(Image_Float* img_in);
    
void Image_Up_Scale(Image* img_raw, Image* img_out, float scaleF, int is_add_residual);
    
Image_Float* Image_Add_Residual_By_Block_Search(Image_Float* img_in, Image_Float* img_smoothed, Image_Float* img_residual);
Image_Float* Image_Only_Residual(Image* img_raw);
    
Image* Image_Add_Residual_By_Block_Search_U8(Image* img_in, Image* img_smoothed, Image* img_residual);
    
Image* Image_Add_Residual_By_Block_Search_U8_Neon(Image* img_in, Image* img_smoothed, int* img_residual, float residual_amount);
    
void Image_Deconv_Sharpen(Image* imgIn, Image* imgOut, float deconv_amount, float deconv_radius, float deconv_damping, int deconv_iter);

#ifdef __cplusplus
}
#endif

#endif