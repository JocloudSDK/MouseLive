//
//  SYEffectsFileHelper.m
//  MouseLive
//
//  Created by GasparChu on 2020/4/13.
//  Copyright © 2020 sy. All rights reserved.
//

#import "SYEffectsFileHelper.h"

static NSString * const BeautyResource = @"BeautyResource";
@implementation SYEffectsFileHelper

+ (NSString *)effectsResourcePathWithTypeName:(NSString *)typeName
{
    NSString *docPath = [SYEffectsFileHelper docPath];
    NSString *beautyFilePath = [docPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@", BeautyResource, typeName]];
    if (![[NSFileManager defaultManager] fileExistsAtPath:beautyFilePath]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:beautyFilePath
                                  withIntermediateDirectories:YES
                                                   attributes:@{NSFileCreationDate:[NSDate date]}
                                                        error:nil];
    }
    return beautyFilePath;
}

+ (BOOL)cacheIsExistWithUrlString:(NSString *)urlString typeName:(NSString *)typeName
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *path = [[self effectsResourcePathWithTypeName:typeName] stringByAppendingPathComponent:url.lastPathComponent];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    return isExist;
}

+ (NSString *)effectResourcePathWithUrlString:(NSString *)urlString typeName:(NSString *)typeName
{
    NSURL *url = [NSURL URLWithString:urlString];
    NSString *path = [NSString stringWithFormat:@"%@/%@", [self effectsResourcePathWithTypeName:typeName], url.lastPathComponent];//[[self effectsResourcePathWithTypeName:typeName] stringByAppendingPathComponent:url.lastPathComponent];
    return path;
}

+ (NSString *)docPath
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    return paths.firstObject;
}

@end
