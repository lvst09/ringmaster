//
//  PreHeader.h
//  catRing
//
//  Created by sky on 15/4/12.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#ifndef catRing_PreHeader_h
#define catRing_PreHeader_h

#define kDevelop 1

#define kUseLowResolution 0

#ifdef DEBUG
#define dprintf(format,args...) \
{\
    printf("************** %s -> %s() -> L%d:",__FILE__, __FUNCTION__, __LINE__);\
    printf(format,##args);\
}
#else
#define dprintf(format,args...) (void)(0)
#endif
//#define printf(format,args...) (void)(0)

#define DLog(fmt, ...) NSLog((@"%s [Line %d]" fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)

//#define DLog(...) {}
//#define NSLog(...) {}



#endif
