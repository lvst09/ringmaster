//
//  LabelSliderGroup.m
//  
//
//  Created by Sky on 13-12-20.
//  Copyright (c) 2013年 DW. All rights reserved.
//

#import "LabelSliderGroup.h"
#import "SliderBar.h"

@implementation SliderTooltip

- (id)init {
    if (self = [super init]) {
        [self setup];
    }
    return self;
}

- (void)setup {
    UIImageView *background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 34, 26)];
    background.image = [UIImage imageNamed:@"tooltip_bg.png"];
    [self addSubview:background];
    
    self.label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 34, 20)];
    //self.label.textColor = [UIColor colorWithRed:0x38/255.0 green:0x3e/255.0 blue:0x4c/255.0 alpha:1.0];
    self.label.textColor = [UIColor redColor];
    self.label.font = [UIFont systemFontOfSize:10];
    self.label.textAlignment = NSTextAlignmentCenter;
    self.label.backgroundColor = [UIColor clearColor];
    [self addSubview:self.label];
}

@end

#pragma mark - LabelSlider

@implementation LabelSlider

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        _slider = [[UISlider alloc] initWithFrame:self.bounds];
        [_slider addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown];
        [_slider addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpInside];
        [_slider addTarget:self action:@selector(touchUp:) forControlEvents:UIControlEventTouchUpOutside];
        [_slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:_slider];
//        [_slider modifyStyle];
        CGRect rect = _slider.frame;
        rect.origin.y = (self.frame.size.height - rect.size.height)*0.5f;
        _slider.frame = rect;
        
        self.tooltip = [[SliderTooltip alloc] init];
        self.tooltip.frame = CGRectMake(0, -26, 34, 26);
        self.tooltip.hidden = YES;
        [self addSubview:self.tooltip];
        
        self.percentMin = 0;
        self.percentMax = 100;
        
        [self resetTooltipCenter];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.percentMin = 0;
        self.percentMax = 100;
    }
    return self;
}

- (void)awakeFromNib
{
//    [_slider modifyStyle];
    CGRect rect = _slider.frame;
    rect.origin.y = (self.frame.size.height - rect.size.height)*0.5f;
    _slider.frame = rect;
    
    self.tooltip = [[SliderTooltip alloc] init];
    self.tooltip.frame = CGRectMake(0, -26, 34, 26);
    self.tooltip.hidden = YES;
    [self addSubview:self.tooltip];
    
    [self resetTooltipCenter];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect superRect = self.bounds;
    
    CGRect sliderRect = _slider.frame;
    sliderRect.origin.y = (superRect.size.height - sliderRect.size.height)*0.5f;
    _slider.frame = sliderRect;
    
    {
        CGFloat minValue = self.slider.minimumValue;
        CGFloat maxValue = self.slider.maximumValue;
        CGFloat value = self.slider.value;
        
        CGRect frame = sliderRect;
        CGPoint center = self.tooltip.center;
        
        CGFloat percent = (value - minValue)/(maxValue - minValue);
        
        float sliderRange = frame.size.width - self.slider.currentThumbImage.size.width;
        float sliderOrigin = frame.origin.x + (self.slider.currentThumbImage.size.width * 0.5f);
        
        center.x = sliderOrigin + sliderRange * percent;
        self.tooltip.center = center;
    }
}

- (void)resetTooltipCenter {
    CGFloat minValue = self.slider.minimumValue;
    CGFloat maxValue = self.slider.maximumValue;
    CGFloat value = self.slider.value;
    
    CGRect frame = self.slider.frame;
    CGPoint center = self.tooltip.center;
    
    CGFloat percent = (value - minValue)/(maxValue - minValue);
    
    float sliderRange = frame.size.width - self.slider.currentThumbImage.size.width;
    float sliderOrigin = frame.origin.x + (self.slider.currentThumbImage.size.width * 0.5f);

    center.x = sliderOrigin + sliderRange * percent;
    self.tooltip.center = center;
    percent = percent * (maxValue - minValue) + minValue;
//    percent = percent * (self.percentMax - self.percentMin) + self.percentMin;
    self.tooltip.label.text = [NSString stringWithFormat:@"%d",(int)percent];
}

#pragma mark - Event
- (void)touchDown:(id)sender {
    self.tooltip.hidden = NO;
    if (self.listener) {
        [_listener sliderBarSlideBegan:sender];
    }
}

- (void)touchUp:(id)sender {
    self.tooltip.hidden = YES;
    if (self.listener) {
        [_listener sliderBarSlideEnded:sender];
    }
}

- (void)sliderValueChanged:(id)sender {
    [self resetTooltipCenter];
    if (self.listener) {
        [_listener sliderBarValueChanged:sender];
    }
}

- (void)setSliderBarStyle:(BOOL)sliderBarStyle
{
    if (_sliderBarStyle != sliderBarStyle)
    {
        _sliderBarStyle = sliderBarStyle;
        
//        if (sliderBarStyle)
//        {
//            [_slider modifyStyleClassic];
//        }
//        else
//        {
//            [_slider modifyStyle];
//        }
    }
}

@end



@interface LabelManualSlider : UIView

@property (retain, nonatomic) UIButton *manualBtn;
@property (retain, nonatomic) UILabel *noFaceInfoLabel;
@property (retain, nonatomic) LabelSlider *labelSlider;

@property (nonatomic, assign) BOOL sliderBarStyle;

@end

@implementation LabelManualSlider

- (id)initWithFrame:(CGRect)frame
{
    return [super initWithFrame:frame];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [super initWithCoder:aDecoder];
}

- (void)setSliderBarStyle:(BOOL)sliderBarStyle
{
    if (_sliderBarStyle != sliderBarStyle)
    {
        _sliderBarStyle = sliderBarStyle;
        
        _labelSlider.sliderBarStyle = sliderBarStyle;
    }
}

@end

#pragma mark - LabelSliderGroup

@interface LabelSliderGroup ()
{
    NSMutableArray *sliderList;
    BOOL isFirst;
}

@end

@implementation LabelSliderGroup

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        isFirst = YES;
        sliderList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        isFirst = YES;
        sliderList = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [self clearContent];
}

- (void)awakeFromNib
{
    
}

- (void)setSliderBarStyle:(BOOL)sliderBarStyle
{
    if (_sliderBarStyle != sliderBarStyle)
    {
        _sliderBarStyle = sliderBarStyle;
        
        for (NSInteger i = 0; i < sliderList.count; i++)
        {
            LabelSlider *slider = [sliderList objectAtIndex:i];
            slider.sliderBarStyle = _sliderBarStyle;
        }
    }
}

- (void)layoutWithList:(NSArray *)list withDelegate:(id<SliderBarEvent>)delegate
{
//    if (isFirst) {
//        isFirst = NO;
//        self.oldOriginY = self.frame.origin.y;
//    }
    [self clearContent];
    if (list == nil || list.count == 0) {
        return;
    }
    CGRect frame = CGRectZero;
    for (NSInteger i = 0; i < list.count; i++) {
        NSDictionary *info = [list objectAtIndex:i];
        LabelSlider *slider = [self createStrengthenSlider:info];
        slider.slider.tag = i;
        CGRect sliderFrame = slider.frame;
        sliderFrame.origin.y = i * CGRectGetHeight(sliderFrame);
        slider.frame = sliderFrame;
        frame = CGRectUnion(frame, sliderFrame);
        slider.listener = delegate;
        [self addSubview:slider];
        slider.sliderBarStyle = _sliderBarStyle;
        [sliderList addObject:slider];
    }
    frame.origin.y = self.oldOriginY + 20;
    frame.size.height = frame.size.height + 4;
    self.frame = frame;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect superRect = self.bounds;
    
    float allSilderHeight = 0;
    if (sliderList.count > 0)
    {
        for (LabelManualSlider *slider in sliderList)
        {
            CGRect sliderFrame = slider.frame;
            allSilderHeight += CGRectGetHeight(sliderFrame);
        }
        allSilderHeight += (sliderList.count - 1) * 2.0f;
    }
    
    float offy = (superRect.size.height - allSilderHeight) * 0.5f;
    for (NSInteger i = 0; i < sliderList.count; i++)
    {
        LabelManualSlider *slider = [sliderList objectAtIndex:i];
        CGRect sliderFrame = slider.frame;
        sliderFrame.origin.y = offy;
        slider.frame = sliderFrame;
        
        offy += CGRectGetHeight(sliderFrame)+2;
    }
}

#pragma mark - Internal Methods
- (void)clearContent
{
    if (sliderList == nil || sliderList.count == 0) {
        return;
    }
    for (UIView *slider in sliderList) {
        if ([slider isKindOfClass:[LabelManualSlider class]]) {
            [((LabelManualSlider*) slider) labelSlider].listener = nil;
        } else if ([slider isKindOfClass:[LabelSlider class]]) {
            ((LabelSlider*) slider).listener = nil;
        }
        [slider removeFromSuperview];
    }
    [sliderList removeAllObjects];
}

- (LabelSlider *)createStrengthenSlider:(NSDictionary *)info
{
    NSBundle *nibBundle = [NSBundle bundleForClass:[LabelSliderGroup class]];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([LabelSliderGroup class]) bundle:nibBundle];
    NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
    LabelSlider *slider = [nibObjects objectAtIndex:0];
    
    slider.label.textColor = [UIColor blueColor];
    slider.label.text = [info objectForKey:@"title"];
    slider.slider.value = [[info objectForKey:@"value"] floatValue];
    if (info[@"percentMin"]) {
        slider.percentMin = [info[@"percentMin"] floatValue];
    }
    if (info[@"percentMax"]) {
        slider.percentMax = [info[@"percentMax"] floatValue];
    }
    [slider.slider addTarget:self action:@selector(handleSliderChangeEvent:) forControlEvents:UIControlEventValueChanged];
    [slider.slider addTarget:self action:@selector(handleSliderUpEvent:) forControlEvents:UIControlEventTouchUpInside];
    [slider.slider addTarget:self action:@selector(handleSliderUpEvent:) forControlEvents:UIControlEventTouchUpOutside];
    [slider resetTooltipCenter];
    return slider;
}

- (LabelManualSlider *)createManualSlider:(NSDictionary *)info
{
    LabelManualSlider *slider = [[LabelManualSlider alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, 50)];
    
    float subviewOffy = -18;
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    const int iconWidth = 25;
    const int padding = 10;
    button.frame = CGRectMake([UIScreen mainScreen].bounds.size.width-40-10, subviewOffy+34-4-10, iconWidth+padding*2, iconWidth+padding*2);
    button.contentEdgeInsets = UIEdgeInsetsMake(padding, padding, padding, padding);
    UIImage *handImage = [UIImage imageNamed:@"hand_normal.png"];
    [button setImage:handImage forState:UIControlStateNormal];
    [button setImage:handImage forState:UIControlStateHighlighted];
    [button setImage:handImage forState:UIControlStateSelected];
    [[button titleLabel] setFont:[UIFont systemFontOfSize:13]];
    
    slider.manualBtn = button;
    
    // slider
    LabelSlider *labelSlider = [[LabelSlider alloc] initWithFrame:CGRectMake(75-4, subviewOffy+30, 170, 23)];
    [labelSlider.slider addTarget:self action:@selector(handleSliderUpEvent:) forControlEvents:UIControlEventTouchUpInside];
    //[labelSlider.slider modifyStyle];
    labelSlider.label.text = nil;
    
    labelSlider.slider.value = [[info objectForKey:@"value"] floatValue];
    labelSlider.slider.minimumValue = 0.0f;
    labelSlider.slider.maximumValue = 1.0f;
    
    slider.labelSlider = labelSlider;
    
    CGRect sliderFrame = labelSlider.slider.frame;
    labelSlider.slider.frame = CGRectMake(labelSlider.label.frame.origin.x+labelSlider.label.frame.size.width+4, sliderFrame.origin.y, sliderFrame.size.width, sliderFrame.size.height);
//    slider.labelSlider.label.text = [info objectForKey:@""];
    [slider addSubview:slider.labelSlider];
    [slider addSubview:slider.manualBtn];

    
    NSString *hasFaceInfo = [info objectForKey:@"hasFaceInfo"];
    if (hasFaceInfo && [hasFaceInfo boolValue]) {
        slider.noFaceInfoLabel = nil;
        
    } else {
        NSString *noFaceInfoText = [info objectForKey:@"noFaceInfoText"];
        if (noFaceInfoText) {
            slider.labelSlider.hidden = YES;
            slider.labelSlider = nil;
            slider.noFaceInfoLabel = [[UILabel alloc] initWithFrame:CGRectMake(35+35, subviewOffy+28-12, 250, 50)];
            [slider.noFaceInfoLabel setText:noFaceInfoText];
            
            slider.noFaceInfoLabel.textColor = [UIColor colorWithRed:0xf9/255.f green:0x6b/255.f blue:0x71/255.f alpha:1.f];
            slider.noFaceInfoLabel.backgroundColor = [UIColor clearColor];
            slider.noFaceInfoLabel.font = [UIFont systemFontOfSize:15.f];
            slider.noFaceInfoLabel.shadowColor = nil;
            slider.noFaceInfoLabel.textAlignment = NSTextAlignmentLeft;
            [slider addSubview:slider.noFaceInfoLabel];
        }
        
        UIImageView *pointToView = [[UIImageView alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width-35-44, subviewOffy+141-13-72, 44, 13)];
        pointToView.image = [UIImage imageNamed:@"arrow.png"];
        [slider addSubview:pointToView];
    }
    
//    slider.label.text = [info objectForKey:@"title"];
    slider.labelSlider.slider.value = [[info objectForKey:@"value"] floatValue];
    [slider.labelSlider.slider addTarget:self action:@selector(handleSliderChangeEvent:) forControlEvents:UIControlEventValueChanged];
    [slider.labelSlider.slider addTarget:self action:@selector(handleSliderUpEvent:) forControlEvents:UIControlEventTouchUpInside];
    [slider.labelSlider.slider addTarget:self action:@selector(handleSliderUpEvent:) forControlEvents:UIControlEventTouchUpOutside];
    
    [slider.manualBtn addTarget:self action:@selector(handleManualPatch:) forControlEvents:UIControlEventTouchUpInside];
    

    return slider;
}

- (void)handleSliderChangeEvent:(UISlider *)slider
{
    float progress = 0;
    float progressStride = slider.maximumValue - slider.minimumValue;
    if (progressStride > 0)
    {
        progress = (slider.value - slider.minimumValue) / progressStride;
    }
    [self.delegate valueChanged:slider.value atIndex:slider.tag ofSliderGroup:self progress:progress];
}
- (void)handleSliderUpEvent:(UISlider *)slider
{
    [self.delegate upWithValue:slider.value atIndex:slider.tag ofSliderGroup:self];
}
- (void)handleManualPatch:(id)sender
{
}



@end


