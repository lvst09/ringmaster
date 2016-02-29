//
//  CPUImageOutput.h
//  FilterShowcase
//
//  Created by Patrick Yang on 12-6-27.
//  Copyright (c) 2012年 Cell Phone. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <UIKit/UIKit.h>
@protocol CPUImageInput <NSObject>
@required
- (void)setInputImages:(NSArray *)images;
@end

@interface CPUImageOutput : NSObject
@property (nonatomic, retain) id<CPUImageInput> target;

- (UIImage *)main;
@end

