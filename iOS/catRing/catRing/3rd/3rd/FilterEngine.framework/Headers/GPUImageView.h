#import <UIKit/UIKit.h>
#import "GPUImageOpenGLESContext.h"

@interface GPUImageView : UIView <GPUImageInput>
{
}


@property (nonatomic, readonly) CGSize sizeInPixels;

- (void)clearVideo;
- (void)updateDisplayBuffer;

@end
