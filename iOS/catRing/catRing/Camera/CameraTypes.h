//
//  CameraTypes.h
//  
//
//  Created by Sky on 13-8-28.
//  Copyright (c) 2013年 DW. All rights reserved.
//

#ifndef MyCam_CameraTypes_h
#define MyCam_CameraTypes_h

#define LOG_METHOD
#define LOG_E(...)

#define DBG_D(a)
#define LOG_D(...)



#define CameraExposureDurationBeauty    (-2)
#define CameraExposureDurationClose     (-1)
#define CameraExposureDurationAuto      0
#define CameraExposureDuration1S        1
#define CameraExposureDuration2S        2
#define CameraExposureDuration4S        4
#define CameraExposrueDuration8S        8

typedef enum {
    CameraDeviceEvent_Started = 0,
    CameraDeviceEvent_Stopped ,
    CameraDeviceEvent_Restarted,
    CameraDeviceEvent_FrameStarted,
    CameraDeviceEvent_FrameReceived,
    CameraDeviceEvent_PositionChanged,
    CameraDeviceEvent_FlashModeSetted,
    CameraDeviceEvent_FocusBegan,
    CameraDeviceEvent_FocusEnded,
    CameraDeviceEvent_ExposureBegan,
    CameraDeviceEvent_ExposureEnded
} CameraDeviceEvent;

typedef enum {
    CameraControllerEvent_Started = 0,
    CameraControllerEvent_Stopped,
    CameraControllerEvent_Restarted,
    CameraControllerEvent_VideoReceived,
    CameraControllerEvent_PositionChanged,
    CameraControllerEvent_FocusBegan,
    CameraControllerEvent_FcousEnded,
    CameraControllerEvent_CaptureBegan,
    CameraControllerEvent_CaptureEnded,
    CameraControllerEvent_CaptureProcessBegan,
    CameraControllerEvent_CaptureProcessEnded,
    CameraControllerEvent_CaptureError,
} CameraControllerEvent;

typedef enum {
    CameraUIEvent_Flash = 0,
    CameraUIEvent_Timer,
    CameraUIEvent_Camera,
    CameraUIEvent_Album,
    CameraUIEvent_More,
    CameraUIEvent_Photo,
    CameraUIEvent_Group,
    CameraUIEvent_Light,
    CameraUIEvent_Duration,
    CameraUIEvent_Exposure,
    CameraUIEvent_Zoom
} CameraUIEvent;

typedef enum {
    CameraFlashModeAuto   = 0,
    CameraFlashModeOff    = 1,
    CameraFlashModeOn     = 2,
    CameraFlashModeLight  = 3,
    CameraFlashModeNone   = 4,
} CameraFlashMode;



#endif
