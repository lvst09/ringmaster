//
//  ManualLongLegHandle.h
//  FilterEngine
//
//  Created by patyang on 14/8/28.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#ifndef FilterEngine_ManualLongLegHandle_h
#define FilterEngine_ManualLongLegHandle_h

#include "type_common.h"
#include "ManualHandleBase.hpp"

class SpringMorph;
class ManualLongLegHandle:ManualHandleBase{
public:
	ManualLongLegHandle(Image *srcImage);
	virtual ~ManualLongLegHandle();
    void setRange(int start, int end);
    void getRange(int &start, int &end);
    void setMag(float mag);
	Image *displayImage();
	int canUndo();
    int canRedo();
	void undoActionImage();
    void redoActionImage();
	int isRawImage();
    
private:    
    Image *out_image;
    SpringMorph *sm;
    
    int start_line;
    int end_line;

    float mag_value;
    
    int s32UndoTimes;
    int s32RedoTimes;
    int s32StackIndex;
    Image *apstImageStack[MAX_UNDO_REAL];
    int apstLines[MAX_UNDO_REAL][2];
};

#endif
