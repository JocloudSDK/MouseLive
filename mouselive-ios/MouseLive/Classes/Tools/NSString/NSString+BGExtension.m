//
//  NSString+Extension.m
//  IdealCallCenter
//
//  Created by 宁丽环 on 15/9/7.
//  Copyright © 2015年 com.Ideal. All rights reserved.
//

#import "NSString+BGExtension.h"
#import "CommonCrypto/CommonDigest.h"
#import <CommonCrypto/CommonHMAC.h>

@implementation NSString (BGExtension)

// 清空字符串中的空白字符
- (NSString *)yy_trimString
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

/**
 *  判断是否为空
 */
- (BOOL)yy_notEmptyOrNull
{
    if ([self isEqualToString:@""]||[self isEqualToString:@"null"] || [self isEqualToString:@"\"\""] || [self isEqualToString:@"''"]||!self) {
        return NO;
    }
    return YES;
}

// 写入系统偏好
- (void)yy_saveToNSDefaultsWithKey:(NSString *)key
{
    [[NSUserDefaults standardUserDefaults] setObject:self forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}


- (BOOL)containsString:(NSString *)aString
{
    NSRange range = [[self lowercaseString] rangeOfString:[aString lowercaseString]];
    return range.location != NSNotFound;
}


// 删除符号
- (NSString *)yy_trimSymbol
{
    NSString *string = self;
    if ([self containsString:@"-"]) {
        string = [string stringByReplacingOccurrencesOfString:@"-" withString:@""];
    }
    
    if ([self containsString:@" "]) {
        string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
    
    if ([string containsString:@"("]) {
        string = [string stringByReplacingOccurrencesOfString:@"(" withString:@""];
    }
    
    if ([self containsString:@")"]) {
        string = [string stringByReplacingOccurrencesOfString:@")" withString:@""];
    }
    
    return string;
}


// 判断手机号码是否正确
- (BOOL)yy_isPhoneNum
{
    // 1.去掉空格，取出第一个数字
    NSString *phone = [self yy_trimString];
    NSString *prefix = nil;
    if (phone.length > 0) {
        prefix = [phone substringToIndex:1];
    } else {
        prefix = @"";
    }
    
    if (phone.length != 11 || (![prefix  isEqual: @"1"] || ![self yy_isPureNum])) {
        // 2.1 号码没有11位、或者首个数据不是1、或者不是纯数字组成
        return 0;
    } else {
        // 2.2 号码正确
        return 1;
    }
}

// 判断是否是邮箱
- (BOOL)yy_isEmail
{
    NSString *regex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex];
    return [predicate evaluateWithObject:self];
}


// 判断是否是纯数字
- (BOOL)yy_isPureNum
{
    NSScanner *scan = [NSScanner scannerWithString:self];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}

// 判断输入的内容是否为字母
- (BOOL)yy_isLetter
{
    NSString *numberRegex = @"^[A-Za-z]*$";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",numberRegex];
    return [numberTest evaluateWithObject:self];
}

// 判断密码位数是否正确
- (BOOL)yy_isLengthBetween:(int)num1 and:(int)num2
{
    int max = (num1 > num2) ? num1 : num2;
    int min = (num1 > num2) ? num2 : num1;
    if (self.length <= max && self.length >= min) {
        return YES;
    } else {
        return NO;
    }
}

//// 是否包含某个字符串
//- (BOOL)containsStr:(NSString *)str
//{
//    NSRange range = [self rangeOfString:str];
//    if (range.location == NSNotFound) {
//        return NO;
//    } else {
//        return YES;
//    }
//}

//转换为md5
- (NSString *) yy_md5String
{
    const char *cStr = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (unsigned int)strlen(cStr), result);
    
    return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}

+ (NSString *)yy_stringFromJsonObject:(id)objc
{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:objc options:0 error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}

- (id)yy_jsonObjectFromString
{
    if (self == nil) {
        return nil;
    }
    NSData *jsonData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id objc = [NSJSONSerialization JSONObjectWithData:jsonData options:0 error:&err];
    if (err) {
        YYLogError(@"json解析失败：%@",err);
        return nil;
    }
    return objc;
}

- (NSString *)yy_stringByReplacingChineseCharacter
{
    //    NSCharacterSet *encodeUrlSet = [NSCharacterSet URLQueryAllowedCharacterSet];
    //    NSString *replacingString = [self stringByAddingPercentEncodingWithAllowedCharacters:encodeUrlSet];
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                                                                    (CFStringRef)self,(CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",NULL,kCFStringEncodingUTF8));
    return encodedString;
}


//字符串包含表情
+ (BOOL)yy_stringContainsEmoji:(NSString *)string
{
    __block BOOL returnValue = NO;
    
    [string enumerateSubstringsInRange:NSMakeRange(0, [string length])
                               options:NSStringEnumerationByComposedCharacterSequences
                            usingBlock:^(NSString *substring, NSRange substringRange, NSRange enclosingRange, BOOL *stop) {
                                const unichar hs = [substring characterAtIndex:0];
                                if (0xd800 <= hs && hs <= 0xdbff) {
                                    if (substring.length > 1) {
                                        const unichar ls = [substring characterAtIndex:1];
                                        const int uc = ((hs - 0xd800) * 0x400) + (ls - 0xdc00) + 0x10000;
                                        if (0x1d000 <= uc && uc <= 0x1f77f) {
                                            returnValue = YES;
                                        }
                                    }
                                } else if (substring.length > 1) {
                                    const unichar ls = [substring characterAtIndex:1];
                                    if (ls == 0x20e3) {
                                        returnValue = YES;
                                    }
                                } else {
                                    if (0x2100 <= hs && hs <= 0x27ff) {
                                        returnValue = YES;
                                    } else if (0x2B05 <= hs && hs <= 0x2b07) {
                                        returnValue = YES;
                                    } else if (0x2934 <= hs && hs <= 0x2935) {
                                        returnValue = YES;
                                    } else if (0x3297 <= hs && hs <= 0x3299) {
                                        returnValue = YES;
                                    } else if (hs == 0xa9 || hs == 0xae || hs == 0x303d || hs == 0x3030 || hs == 0x2b55 || hs == 0x2b1c || hs == 0x2b1b || hs == 0x2b50) {
                                        returnValue = YES;
                                    }
                                }
                            }];
    
    return returnValue;
}



//MARK:文件下载专用md5方法
- (NSString *)yy_md5StringForFile
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_MD5_DIGEST_LENGTH];
    CC_MD5(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_MD5_DIGEST_LENGTH];
}

- (NSString *)yy_sha1String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA1_DIGEST_LENGTH];
}

- (NSString *)yy_sha256String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA256_DIGEST_LENGTH];
    CC_SHA256(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA256_DIGEST_LENGTH];
}

- (NSString *)yy_sha512String
{
    const char *string = self.UTF8String;
    int length = (int)strlen(string);
    unsigned char bytes[CC_SHA512_DIGEST_LENGTH];
    CC_SHA512(string, length, bytes);
    return [self stringFromBytes:bytes length:CC_SHA512_DIGEST_LENGTH];
}

- (NSString *)yy_hmacSHA1StringWithKey:(NSString *)key
{
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *messageData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *mutableData = [NSMutableData dataWithLength:CC_SHA1_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA1, keyData.bytes, keyData.length, messageData.bytes, messageData.length, mutableData.mutableBytes);
    return [self stringFromBytes:(unsigned char *)mutableData.bytes length:mutableData.length];
}

- (NSString *)yy_hmacSHA256StringWithKey:(NSString *)key
{
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *messageData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *mutableData = [NSMutableData dataWithLength:CC_SHA256_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA256, keyData.bytes, keyData.length, messageData.bytes, messageData.length, mutableData.mutableBytes);
    return [self stringFromBytes:(unsigned char *)mutableData.bytes length:mutableData.length];
}

- (NSString *)yy_hmacSHA512StringWithKey:(NSString *)key
{
    NSData *keyData = [key dataUsingEncoding:NSUTF8StringEncoding];
    NSData *messageData = [self dataUsingEncoding:NSUTF8StringEncoding];
    NSMutableData *mutableData = [NSMutableData dataWithLength:CC_SHA512_DIGEST_LENGTH];
    CCHmac(kCCHmacAlgSHA512, keyData.bytes, keyData.length, messageData.bytes, messageData.length, mutableData.mutableBytes);
    return [self stringFromBytes:(unsigned char *)mutableData.bytes length:mutableData.length];
}

#pragma mark - Helpers

- (NSString *)stringFromBytes:(unsigned char *)bytes length:(int)length
{
    NSMutableString *mutableString = @"".mutableCopy;
    for (int i = 0; i < length; i++) {
        [mutableString appendFormat:@"%02x", bytes[i]];
    }
    return [NSString stringWithString:mutableString];
}


//判断中英混合的的字符串长度
- (int)yy_convertToInt
{
    int strlength = 0;
    char *p = (char *)[self cStringUsingEncoding:NSUnicodeStringEncoding];
    for (int i=0; i < [self lengthOfBytesUsingEncoding:NSUnicodeStringEncoding]; i++) {
        if (*p) {
            p++;
            strlength++;
        }
        else {
            p++;
        }
    }
    return strlength;
}

+ (NSString *)yy_base64Escape:(NSString *)string
{
    NSCharacterSet *URLBase64CharacterSet = [[NSCharacterSet characterSetWithCharactersInString:@"/+=\n"] invertedSet];
    return [string stringByAddingPercentEncodingWithAllowedCharacters:URLBase64CharacterSet];
}

+ (NSString *)yy_wwwFormWithDictionary:(NSDictionary *)dict
{
    NSMutableString *result = [[NSMutableString alloc] init];
    if (dict != nil) {
        for (NSString *key in dict) {
            if (result.length) {
                [result appendString:@"&"];
            }
            [result appendString:[self yy_base64Escape:key]];
            [result appendString:@"="];
            [result appendString:[self yy_base64Escape:dict[key]]];
        }
    }
    return result;
}

@end
