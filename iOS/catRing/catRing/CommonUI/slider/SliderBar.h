//
//  SliderBar.h
//  
//
//  Created by Sky on 14-1-20.
//  Copyright (c) 2014年 DW. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    SliderBarStyleNormal = 0,
    SliderBarStyleFilter,
};

@class SliderBar;

@protocol SliderBarEvent <NSObject>

- (void)sliderBarSlideBegan:(id)sender;
- (void)sliderBarValueChanged:(id)sender;
- (void)sliderBarSlideEnded:(id)sender;

@end

@interface SliderBar : UIView

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) BOOL tracking;
@property (nonatomic, assign) NSObject<SliderBarEvent> *listener;

- (void)setSliderBarStyle:(NSInteger)style;
- (void)setHidden:(BOOL)hidden delay:(BOOL)delay;

@end
