//
//  NSString+Extension.h
//  IdealCallCenter
//
//  Created by 宁丽环 on 15/9/7.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//
#import <Foundation/Foundation.h>

@interface NSString (BGExtension)
@property (readonly) NSString *yy_md5StringForFile;
@property (readonly) NSString *yy_sha1String;
@property (readonly) NSString *yy_sha256String;
@property (readonly) NSString *yy_sha512String;

- (NSString *)yy_hmacSHA1StringWithKey:(NSString *)key;
- (NSString *)yy_hmacSHA256StringWithKey:(NSString *)key;
- (NSString *)yy_hmacSHA512StringWithKey:(NSString *)key;

// 清空字符串中的空白字符
- (NSString *)yy_trimString;

// 判断字符串是否为空
- (BOOL)yy_notEmptyOrNull;

// 写入系统偏好
- (void)yy_saveToNSDefaultsWithKey:(NSString *)key;

// 删除符号：()-空格
- (NSString *)yy_trimSymbol;

// 判断手机号码是否正确
- (BOOL)yy_isPhoneNum;

// 判断是否是邮箱
- (BOOL)yy_isEmail;

// 判断是否是纯数字
- (BOOL)yy_isPureNum;

// 判断输入的内容是否为字母
- (BOOL)yy_isLetter;

// 判断长度是否处于num1和num2之间
- (BOOL)yy_isLengthBetween:(int)num1 and:(int)num2;

// 是否包含某个字符串
//- (BOOL)containsString:(NSString *)str;

//转换为md5
- (NSString *)yy_md5String;
//json对象转字符串
+ (NSString *)yy_stringFromJsonObject:(id)objc;
//字符串转json对象
- (id)yy_jsonObjectFromString;

//替换字符串中的中文字符，用于网络链接的转换
- (NSString *)yy_stringByReplacingChineseCharacter;

//字符串包含表情
+ (BOOL)yy_stringContainsEmoji:(NSString *)string;

//判断中英混合的的字符串长度
- (int)yy_convertToInt;

+ (NSString *)yy_base64Escape:(NSString *)string;

+ (NSString *)yy_wwwFormWithDictionary:(NSDictionary *)dict;

@end
