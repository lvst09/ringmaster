//
//  ImageAlgo.h
//  FaceppSDK+Demo
//
//  Created by MAC on 13-12-20.
//  Copyright (c) 2013年 Megvii. All rights reserved.
//
#pragma once

#include "type_common.h"

typedef unsigned char U8;
#define MAX3(v1,v2,v3) MAX(MAX(v1,v2),(v3))
#define MIN3(v1,v2,v3) MIN(MIN(v1,v2),(v3))
#define SQUARE(x) ((x)*(x))
#define SKIN_TONE_TOLERANCE 25

#define R_CHANNEL    (0)
#define G_CHANNEL    (1)
#define B_CHANNEL    (2)
#define A_CHANNEL    (3)

#define EYE_LID_N           (256)
#define PI                  (3.1415926f)
#define EYE_FEATURE_NUM     (9)
#define FACE_FEATURE_NUM    (83)
#define PARAM_NUM           (16)
#define POWER2(a)           ((a) * (a))
#define MIN_EDGE            (3)
#define INSIDE_FACTOR       (0.65f)
#define LEN_FACTOR          (0.2f)
#define RIGHT_START_ANGLE    (-PI/4)
#define RIGHT_END_ANGLE      (PI/4)
#define LEFT_START_ANGLE     (PI*3/4)
#define LEFT_END_ANGLE       (PI*5/4)
#define ANGLE_STEP           (PI/50.0f)
#define DISTANT(x0,y0,x1,y1)   ((int)(sqrt((double)(POWER2((x0) - (x1)) + POWER2((y0) - (y1)))) + 0.5))

#define PIX_DATA(x) ((U8*)x->imageData)

#define CLAMP(x,a,b)         do { \
if ((x) < (a))  \
{   \
    (x) = (a);  \
}   \
else if ((x) > (b)) \
{   \
    (x) = (b);  \
}   \
} while(0)

typedef enum {
    LEFT_EYE = 0,
    RIGHT_EYE
} EYE_ENUM;

typedef struct {
    int x;
    int y;
    int r;
} CIRCLE_STRU;

#define  MAXNUM  32   //定义样条数据区间个数最多为50个
typedef struct SPLINE    //定义样条结构体，用于存储一条样条的所有信息
{ //初始化数据输入
    float x[MAXNUM+1];    //存储样条上的点的x坐标，最多51个点
    float y[MAXNUM+1];    //存储样条上的点的y坐标，最多51个点
    unsigned int point_num;   //存储样条上的实际的 点 的个数
    float begin_k1;     //开始点的一阶导数信息
    float end_k1;     //终止点的一阶导数信息
    //float begin_k2;    //开始点的二阶导数信息
    //float end_k2;     //终止点的二阶导数信息
    //计算所得的样条函数S(x)
    float k1[MAXNUM+1];    //所有点的一阶导数信息
    float k2[MAXNUM+1];    //所有点的二阶导数信息
    //51个点之间有50个段，func[]存储每段的函数系数
    float a3[MAXNUM],a1[MAXNUM];
    float b3[MAXNUM],b1[MAXNUM];
    //分段函数的形式为 Si(x) = a3[i] * {x(i+1) - x}^3  + a1[i] * {x(i+1) - x} +
    //        b3[i] * {x - x(i)}^3 + b1[i] * {x - x(i)}
    //xi为x[i]的值，xi_1为x[i+1]的值
}SPLINE,*pSPLINE;

typedef enum _COS_TYPE {
    COS_BASIC,
    COS_LIPS,
    COS_NOSE,
    COS_SHADOW,
    COS_EYELINE_UP,
    COS_EYELINE_DOWN,
    COS_LASH_UP,
    COS_LASH_DOWN,
    COS_IRIS_COLOR,
    COS_IRIS,
    COS_BLUSH_COLOR,
    COS_BLUSH,
    COS_HAIR,
    COS_EYEBROW,
    COS_BROWSHAPING,
    COS_DOUBLE_EYELID,
    COS_FOREHEAD,
    COS_LEFTEYE,
    COS_RIGHTEYE,
    COS_MOUSE,
    COS_SMOOTH,
    COS_HIGHLIGHT,
    COS_SMILE,
    COS_NONE,
    COS_ALL = 99,
} COS_TYPE;

#define COS_NUM  COS_NONE

typedef struct _parabola_param
{
    int x;
    int y;
    int a;
    int b;
    int xc;
    int yc;
    int r;
} parabola_param;

typedef struct _EyeDetectParam
{
    int x_iris;
    int y_iris;
    int r_iris;
    int eyelid[EYE_LID_N][2];
    double feature[10][2];
    MRect eyeRect;
    
} EyeDetectParam;

