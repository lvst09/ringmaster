//
//  ResourceManager.h
//  FilterEngine
//
//  Created by patyang on 14/12/15.
//  Copyright (c) 2014年 Tencent. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "type_common.h"

@interface ResourceManager : NSObject

@property (nonatomic, strong) NSString *bundleDirctory;

+ (ResourceManager *)shareManager;
- (UIImage *)loadUIImageResource:(NSString *)relative;
- (Image *)loadImageResource:(NSString *)relative;
- (Image *)loadFilterResource:(NSString *)relative;
- (Image *)loadFaceJpgResource:(NSString *)relative;
- (Image *)loadFaceRawResource:(NSString *)relative width:(NSInteger)width height:(NSInteger)height;
- (Image *)loadFaceBmpResource:(NSString *)relative;
- (Image *)loadCurveResource:(NSString *)relative;

@end
