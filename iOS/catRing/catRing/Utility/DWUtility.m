//
//  DWUtility.m
//  catRing
//
//  Created by sky on 15/3/21.
//  Copyright (c) 2015年 DW. All rights reserved.
//

#import "DWUtility.h"


NSString *documentPath()
{
    static NSString * kPath = nil;
    if (kPath == nil)
    {
        kPath = [[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] copy];
    }
    return kPath;
}

@implementation DWUtility

+ (BOOL)createFolder:(NSString *)folder {
    if (!folder)
        return NO;
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:folder])
        return YES;
    
    NSError *error = nil;
    BOOL ret = [fileManager createDirectoryAtPath:folder withIntermediateDirectories:YES attributes:nil error:&error];
    return ret;
}


@end
