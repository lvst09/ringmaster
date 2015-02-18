//
//  LabelSliderGroup.h
//  
//
//  Created by Sky on 13-12-20.
//  Copyright (c) 2013年 DW. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SliderBar.h"

@interface SliderTooltip : UIView

@property (nonatomic,retain) UILabel *label;

@end

@interface LabelSlider : UIView

@property (retain, nonatomic) IBOutlet UILabel *label;
@property (retain, nonatomic) IBOutlet UISlider *slider;
@property (retain, nonatomic) SliderTooltip *tooltip;
@property (assign, nonatomic) id<SliderBarEvent> listener;

@property (nonatomic, assign) BOOL sliderBarStyle;
@property (nonatomic, assign) CGFloat percentMin;
@property (nonatomic, assign) CGFloat percentMax;

- (void)resetTooltipCenter;
- (IBAction)touchDown:(id)sender;
- (IBAction)touchUp:(id)sender;
- (IBAction)sliderValueChanged:(id)sender;

@end


@class LabelSliderGroup;


// slim face segment diagram
//a|  |e
//b\  /d
//  --
//  c
//


@protocol LabelSliderGroupDelegate <NSObject>

@required
- (void)valueChanged:(CGFloat)value atIndex:(NSInteger)index ofSliderGroup:(LabelSliderGroup *)group progress:(float)progress;
- (void)upWithValue:(CGFloat)value atIndex:(NSInteger)index ofSliderGroup:(LabelSliderGroup *)group;

@end

@interface LabelSliderGroup : UIView

@property (assign, nonatomic) NSObject<LabelSliderGroupDelegate> *delegate;
@property (assign, nonatomic) CGFloat oldOriginY;

@property (nonatomic, assign) BOOL sliderBarStyle;

- (void)layoutWithList:(NSArray *)list withDelegate:(id<SliderBarEvent>)delegate;

@end
