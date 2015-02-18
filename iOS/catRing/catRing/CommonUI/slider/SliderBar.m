//
//  SliderBar.m
//
//
//  Created by Sky on 14-1-20.
//  Copyright (c) 2014年 DW. All rights reserved.
//

#import "SliderBar.h"

@interface HorizontalSliderBar : UIView
{
    IBOutlet UIImageView *maxTrack;
    IBOutlet UIImageView *minTrack;
    IBOutlet UIButton *thumb;
    
    CGFloat dragThumb;
    CGPoint downPoint;
}

@property (nonatomic, assign) CGFloat value;
@property (nonatomic, assign) CGFloat minValue;
@property (nonatomic, assign) CGFloat maxValue;
@property (nonatomic, assign) BOOL tracking;
@property (nonatomic, assign) NSObject<SliderBarEvent> *listener;

@end

@implementation HorizontalSliderBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self internalInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)awakeFromNib
{
    [self internalInit];
}

- (void)dealloc
{
}

- (void)setValue:(CGFloat)value
{
    _value = value;
    [self refreshUI];
}
- (void)setMinValue:(CGFloat)minValue
{
    _minValue = minValue;
    [self refreshUI];
}
- (void)setMaxValue:(CGFloat)maxValue
{
    _maxValue = maxValue;
    [self refreshUI];
}
- (BOOL)tracking
{
    return thumb.selected;
}
- (void)setTracking:(BOOL)tracking
{
    thumb.selected = tracking;
}
- (void)setMaxTrackImage:(UIImage *)image
{
    CGFloat delta = image.size.height - CGRectGetHeight(maxTrack.frame);
    maxTrack.frame = UIEdgeInsetsInsetRect(maxTrack.frame, UIEdgeInsetsMake(-delta / 2, 0, -delta / 2, 0));
    minTrack.frame = maxTrack.frame;
    maxTrack.image = image;
}
- (void)setMinTrackImage:(UIImage *)image
{
    CGFloat delta = image.size.height - CGRectGetHeight(minTrack.frame);
    minTrack.frame = UIEdgeInsetsInsetRect(minTrack.frame, UIEdgeInsetsMake(-delta / 2, 0, -delta / 2, 0));
    minTrack.image = image;
}
- (void)setThumbSize:(CGSize)size
{
    CGFloat topBottom = (size.height - CGRectGetHeight(thumb.frame)) / 2;
    CGFloat leftRight = (size.width - CGRectGetWidth(thumb.frame)) / 2;
    thumb.frame = UIEdgeInsetsInsetRect(thumb.frame, UIEdgeInsetsMake(-topBottom, -leftRight, -topBottom, -leftRight));
}
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state
{
    CGFloat topBottom = (image.size.height - CGRectGetHeight(thumb.frame)) / 2;
    CGFloat leftRight = (image.size.width - CGRectGetWidth(thumb.frame)) / 2;
    [thumb setImage:image forState:state];
    thumb.imageEdgeInsets = UIEdgeInsetsMake(-topBottom, -leftRight, -topBottom, -leftRight);
}
- (void)setThumbBackImage:(UIImage *)image forState:(UIControlState)state
{
    [thumb setBackgroundImage:image forState:state];
}

#pragma mark - Internal
- (void)internalInit
{
    _minValue = 0.0f;
    _maxValue = 1.0f;
    _value = 0.5f;
    thumb.userInteractionEnabled = NO;
    [self refreshUI];
}
- (void)refreshUI
{
    CGRect frame = minTrack.frame;
    frame.size.width = CGRectGetWidth(maxTrack.frame) * (self.value - self.minValue) / (self.maxValue - self.minValue);
    minTrack.frame = frame;
    thumb.center = CGPointMake(CGRectGetMaxX(minTrack.frame), thumb.center.y);
}

#pragma mark - Event
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (point.x >= CGRectGetMinX(thumb.frame) && point.y <= CGRectGetMaxX(thumb.frame)) {
        thumb.selected = YES;
    }
    [self.listener sliderBarSlideBegan:nil];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (thumb.selected) {
        point.x = MAX(point.x, CGRectGetMinX(maxTrack.frame));
        point.x = MIN(point.x, CGRectGetMaxX(maxTrack.frame));
        float newVal = (point.x - CGRectGetMinX(maxTrack.frame)) / (CGRectGetMaxX(maxTrack.frame) - CGRectGetMinX(maxTrack.frame)) * (self.maxValue - self.minValue);
        if (self.value != newVal)
        {
            self.value = newVal;
            [self.listener sliderBarValueChanged:nil];
        }
    }
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self];
    if (thumb.selected) {
        point.x = MAX(point.x, CGRectGetMinX(maxTrack.frame));
        point.x = MIN(point.x, CGRectGetMaxX(maxTrack.frame));
        float newVal = (point.x - CGRectGetMinX(maxTrack.frame)) / (CGRectGetMaxX(maxTrack.frame) - CGRectGetMinX(maxTrack.frame)) * (self.maxValue - self.minValue);
        if (self.value != newVal)
        {
            self.value = newVal;
            [self.listener sliderBarValueChanged:nil];
        }
    }
    thumb.selected = NO;
    [self.listener sliderBarSlideEnded:nil];
}
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self touchesEnded:touches withEvent:event];
    [self.listener sliderBarSlideEnded:nil];
}

@end


@interface SliderBar () <SliderBarEvent>
{
    HorizontalSliderBar *horizontalSlider;
}

@end

@implementation SliderBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self InternalInit];
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
    }
    return self;
}

- (void)dealloc
{
    [horizontalSlider removeFromSuperview];
}

- (void)awakeFromNib
{
    [self InternalInit];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    horizontalSlider.frame = self.bounds;
}

- (void)setHidden:(BOOL)hidden
{
    [self setHidden:hidden delay:NO];
}
- (CGFloat)value
{
    return horizontalSlider.value;
}
- (void)setValue:(CGFloat)value
{
    horizontalSlider.value = value;
}
- (CGFloat)minValue
{
    return horizontalSlider.minValue;
}
- (void)setMinValue:(CGFloat)minValue
{
    horizontalSlider.minValue = minValue;
}
- (CGFloat)maxValue
{
    return horizontalSlider.maxValue;
}
- (void)setMaxValue:(CGFloat)maxValue
{
    horizontalSlider.maxValue = maxValue;
}
- (BOOL)tracking
{
    return horizontalSlider.tracking;
}
- (void)setTracking:(BOOL)tracking
{
    horizontalSlider.tracking = tracking;
}

- (void)setSliderBarStyle:(NSInteger)style
{
    switch (style) {
        case SliderBarStyleNormal:
        {
            [horizontalSlider setMaxTrackImage:[[UIImage imageNamed:@"filter_drawbarbg.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)]];
            [horizontalSlider setMinTrackImage:[[UIImage imageNamed:@"filter_drawbarfg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 3, 0, 3)]];
            [horizontalSlider setThumbImage:[UIImage imageNamed:@"slide_btn_normal.png"] forState:UIControlStateNormal];
            [horizontalSlider setThumbImage:[UIImage imageNamed:@"slide_btn_normal.png"] forState:UIControlStateHighlighted];
        }
            break;
        case SliderBarStyleFilter:
        {
            [horizontalSlider setMaxTrackImage:[[UIImage imageNamed:@"slider_white_left.png"]resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)]];
            [horizontalSlider setMinTrackImage:[[UIImage imageNamed:@"slider_white_right.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 8, 0, 8)]];
            [horizontalSlider setThumbImage:[UIImage imageNamed:@"slider_white_trigger.png"] forState:UIControlStateNormal];
            [horizontalSlider setThumbImage:[UIImage imageNamed:@"slider_white_trigger.png"] forState:UIControlStateHighlighted];
        }
            break;
        default:
            break;
    }
}
- (void)setHidden:(BOOL)hidden delay:(BOOL)delay
{
    NSLog(@"SliderBar.setHidden:hidden %d, delay: %d", hidden, delay);
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenDelay:) object:@(YES)];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hiddenDelay:) object:@(NO)];

    if (delay) {
        [self performSelector:@selector(hiddenDelay:) withObject:@(hidden) afterDelay:0.5];
    } else {
        super.hidden = hidden;
    }
}

#pragma mark - Internal
- (void)InternalInit
{
    horizontalSlider = [self createHorizontalSlider];
    horizontalSlider.listener = self;
    [self addSubview:horizontalSlider];
    horizontalSlider.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleHeight;
    CGFloat width = MAX(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    CGFloat height = MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    horizontalSlider.frame = CGRectMake(0, 0, width, height);
    if (CGRectGetWidth(self.bounds) < CGRectGetHeight(self.bounds)) {
        horizontalSlider.center = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        horizontalSlider.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    [self setSliderBarStyle:SliderBarStyleFilter];
}
- (HorizontalSliderBar *)createHorizontalSlider
{
    NSBundle *nibBundle = [NSBundle bundleForClass:[SliderBar class]];
    UINib *nib = [UINib nibWithNibName:NSStringFromClass([SliderBar class]) bundle:nibBundle];
    NSArray *nibObjects = [nib instantiateWithOwner:nil options:nil];
    HorizontalSliderBar *slider = [nibObjects objectAtIndex:0];
    return slider;
}
- (void)hiddenDelay:(NSNumber *)hidden
{
    super.hidden = [hidden boolValue];
}
#pragma mark - SliderBarEvent
- (void)sliderBarSlideBegan:(SliderBar *)sender
{
    [self setHidden:NO delay:NO];
    [self.listener sliderBarSlideBegan:self];
}
- (void)sliderBarValueChanged:(SliderBar *)sender
{
//    [self setHidden:NO delay:NO];
    [self.listener sliderBarValueChanged:self];
}
- (void)sliderBarSlideEnded:(SliderBar *)sender
{
//    [self setHidden:YES delay:YES];
    [self.listener sliderBarSlideEnded:self];
}

@end
