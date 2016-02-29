//
//  CryptoManager.h
//  FilterEngine
//
//  Created by patyang on 14/7/21.
//  Copyright (c) 2014年 Microrapid. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CryptoManager : NSObject

+ (NSString *)decryptShader:(NSString *)shader;
+ (NSData *)decryptData:(NSData *)data;
+ (NSData *)decryptDataWithPath:(NSString *)path;
+ (UIImage *)decryptImageWithPath:(NSString *)path;

@end
