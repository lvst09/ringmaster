#ifndef CONFIG_H
#define CONFIG_H

#include<stdlib.h>
#include<stddef.h>

#ifndef SKETCH_QT
#define RGB   0x01020300
#define RGBA  0x01020304
#define ARGB  0x02030401
#define BGR   0x03020100
#define BGRA  0x03020104
#endif

typedef unsigned char U8;
typedef unsigned char BYTE;
typedef unsigned short U16;
typedef unsigned int U32;

#define SHIFT_NUM 16
#define FLOAT2FIXED(v) ((int)((v) * (1 << SHIFT_NUM)))
#define FIXED2INT(v) ((v) >> SHIFT_NUM)

#ifdef _MSC_VER // for MSVC
    #define forceinline __forceinline
    //#define inline  _inline
#elif defined ANDROID // for gcc on Linux/Apple OS X
    #define forceinline __inline__ __attribute__((always_inline))
#elif defined (IPHONE4)
    #define forceinline
#endif

#undef COLOR_TYPE
#if defined ANDROID 
    #define COLOR_TYPE  RGBA
#elif defined _MSC_VER
    #define COLOR_TYPE  BGRA
#elif defined IPHONE4
    #define COLOR_TYPE  RGBA
#endif


#if COLOR_TYPE == ARGB

#define ALPHA_CHANNEL 0
#define RED_CHANNEL   1
#define GREEN_CHANNEL 2
#define BLUE_CHANNEL  3
#define IMAGE_CHANNELS 4

#define AllocateColor(r, g, b, a)  ((a) | ((r) << 8) | ((g) << 16) | (b) << 24)

#elif COLOR_TYPE == BGRA
#define BLUE_CHANNEL  0
#define GREEN_CHANNEL 1
#define RED_CHANNEL   2
#define ALPHA_CHANNEL 3
#define IMAGE_CHANNELS 4

#define AllocateColor(r, g, b, a)  ((a) << 24 | ((r) << 16) | ((g) << 8) | (b))

#elif  COLOR_TYPE == RGBA

#define RED_CHANNEL   0
#define GREEN_CHANNEL 1
#define BLUE_CHANNEL  2
#define ALPHA_CHANNEL 3
#define IMAGE_CHANNELS 4
#define AllocateColor(r, g, b, a)  ((a) << 24 | ((r) ) | ((g) << 8) | (b << 16))
#endif
#define  NEREUS_FREE(p)      free((p))
#define  NEREUS_MALLOC(size)  malloc((size))
#define  NEREUS_NEW(type)     (type*)malloc(sizeof(type))
#define  NEREUS_NEW_ARRAY(type, n)   (type*)malloc(sizeof(type) * (n))

#endif