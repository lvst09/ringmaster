//
//  OriginalImageFilterWrapper.h
//  My Cam
//
//  Created by rexyuan on 13-6-19.
//  Copyright (c) 2013å¹?Microrapid. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@protocol OriginalImageFilterDelegate <NSObject>
-(void)originalProgressFinished:(UIImage *)result;
-(void)originalProgressing:(CGFloat)currunt;
@end

@interface OriginalImageFilterWrapper : NSObject
@property (nonatomic, assign) id<OriginalImageFilterDelegate> delegate;
- (void)processorOriginalImage:(UIImage *)originalImage andScreenImage:(UIImage *)screenImage withParam:(NSArray*)filterParam;
- (void)stopProgress;
@end
