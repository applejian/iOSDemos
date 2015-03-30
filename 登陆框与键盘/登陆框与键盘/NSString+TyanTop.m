//
//  NSString+TyanTop.m
//  CDoom
//
//  Created by ChenLi on 14-5-12.
//  Copyright (c) 2014年 HNMDD. All rights reserved.
//

#import "NSString+TyanTop.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>

@implementation NSString (TyanTop)

+(BOOL) isValidEmail:(NSString *)checkingStr
{
    BOOL stricterFilter = YES; // Discussion http://blog.logichigh.com/2010/09/02/validating-an-e-mail-address/
    NSString *stricterFilterString = @"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}";
    NSString *laxString = @".+@([A-Za-z0-9]+\\.)+[A-Za-z]{2}[A-Za-z]*";
    NSString *emailRegex = stricterFilter ? stricterFilterString : laxString;
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    
    return [emailTest evaluateWithObject:checkingStr];
}

+(BOOL) isValidMobilePhoneNumber:(NSString *)checkingStr
                           error:(NSError **)error
{
    unsigned long strLenght = 0;
    // 1. user id length check
    strLenght = [checkingStr length];
    if (strLenght != CDOOM_PHONENUM_LENGTH)
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"手机号码长度错误。" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        *error = [NSError errorWithDomain:@"Phone Number" code:101 userInfo:details];
        return false;
    }
    
    // 2. phone number content check
    // 2.1 only number included
    NSString *textfieldStr;
    NSRange strRange;
    NSCharacterSet *alphaSet =
    [NSCharacterSet characterSetWithCharactersInString:@"1234567890"];
    alphaSet = [alphaSet invertedSet];
    
    textfieldStr = checkingStr;
    strRange = [textfieldStr rangeOfCharacterFromSet:alphaSet];
    if (strRange.location != NSNotFound)
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"手机号码包含非法字符。" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        *error = [NSError errorWithDomain:@"Phone Number" code:102 userInfo:details];
        return false;
    }
    
    // 2.2 1st number should be 1; 2nd number should not be "0, 1, 2"
    if ([checkingStr hasPrefix:@"1"])
    {
        NSString * index2nd = [checkingStr substringWithRange:NSMakeRange(1, 1)];
        if ([index2nd compare:@"0"] == NSOrderedSame ||
            [index2nd compare:@"1"] == NSOrderedSame ||
            [index2nd compare:@"2"] == NSOrderedSame)
        {
            NSMutableDictionary* details = [NSMutableDictionary dictionary];
            [details setValue:@"手机号码段非法。" forKey:NSLocalizedDescriptionKey];
            // populate the error object with the details
            *error = [NSError errorWithDomain:@"Phone Number" code:103 userInfo:details];
            return false;
        }
        return true;
    }
    
    NSMutableDictionary* details = [NSMutableDictionary dictionary];
    [details setValue:@"手机号码段非法。" forKey:NSLocalizedDescriptionKey];
    // populate the error object with the details
    *error = [NSError errorWithDomain:@"Phone Number" code:100 userInfo:details];
    return false;
}

+(BOOL) isValidPassword:(NSString *)checkingStr
                  error:(NSError **)error
{
    unsigned long strLenght = 0;
    // 4. password length check
    strLenght = [checkingStr length];
    if (strLenght < CDOOM_PASSWORD_LENGTH_MIN ||
        strLenght > CDOOM_PASSWORD_LENGTH_MAX)
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"密码长度错误。" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        *error = [NSError errorWithDomain:@"Password" code:101 userInfo:details];
        return false;
    }
    
    // 5. password content check
    NSString *textfieldStr;
    NSRange strRange;
    NSCharacterSet *alphaSet =
    [NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_"];
    alphaSet = [alphaSet invertedSet];
    
   textfieldStr = checkingStr;
    strRange = [textfieldStr rangeOfCharacterFromSet:alphaSet];
    if (strRange.location != NSNotFound)
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"密码含有非法字符。" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        *error = [NSError errorWithDomain:@"Password" code:102 userInfo:details];
        return false;
    }
    return true;
}

+(BOOL) isValidVerifyCode:(NSString *)checkingStr
                    error:(NSError **)error
{
    unsigned long strLenght = 0;
    // 4. password length check
    strLenght = [checkingStr length];
    if (strLenght <= 0)
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"校验码为空。" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        *error = [NSError errorWithDomain:@"Verify Code" code:100 userInfo:details];
        return false;
    }
    
    return true;
}

+(BOOL) isValidNickName:(NSString *)checkingStr
                  error:(NSError **)error
{
    unsigned long strLenght = 0;
    // 4. password length check
    strLenght = [checkingStr length];
    if (strLenght < 2 || strLenght > 16)
    {
        NSMutableDictionary* details = [NSMutableDictionary dictionary];
        [details setValue:@"昵称长度有误。" forKey:NSLocalizedDescriptionKey];
        // populate the error object with the details
        *error = [NSError errorWithDomain:@"Nick Name" code:100 userInfo:details];
        return false;
    }
    
    return true;
}

+ (NSString *) encodeMD5:(NSString *)codingStr
{
    // *************************************************************
    // password MD5 compute!
    const char *utfPassword = [codingStr UTF8String];
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(utfPassword, (CC_LONG)strlen(utfPassword), md5Buffer);
    
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *PWMD5Str =
    [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [PWMD5Str appendFormat:@"%02x", md5Buffer[i]];
    
    return [PWMD5Str uppercaseString];
}


Byte iv [] = {1, 2, 3, 4, 5, 6, 7, 8};
+(NSString *) encryptDES:(NSData *)codingData withKey:(NSString *)enKey
{
    // 1. convert to gbk encoding
    
    size_t numBytesEncrypted = 0;
    size_t bufferSize = codingData.length + kCCBlockSizeDES;
    void *buffer = malloc(bufferSize);
    
    NSData *key = [enKey dataUsingEncoding:NSUTF8StringEncoding];
 
    CCCryptorStatus result = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmDES,
                                     kCCOptionPKCS7Padding,
                                     key.bytes,
                                     kCCKeySizeDES,
                                     iv,
                                     codingData.bytes,
                                     codingData.length,
                                     buffer,
                                     bufferSize,
                                     &numBytesEncrypted);
    NSData *output = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    
    if( result == kCCSuccess )
    {
        // 2. base 64 string encode
        return [output base64EncodedStringWithOptions:0];;
    }
    else
    {
        NSLog(@"Failed DES encrypt...");
        return nil;
    }
}

// jason add
+(NSString *) forYunWanEncryptDES:(NSData *)codingData withKey:(NSString *)enKey
{
    size_t numBytesEncrypted = 0;
    size_t bufferSize = codingData.length + kCCBlockSizeDES;
    void *buffer = malloc(bufferSize);
    
    NSData *key = [enKey dataUsingEncoding:NSUTF8StringEncoding];
    
    CCCryptorStatus result = CCCrypt(kCCEncrypt,
                                     kCCAlgorithmDES,
                                     kCCOptionPKCS7Padding,
                                     key.bytes,
                                     kCCKeySizeDES,
                                     iv,
                                     codingData.bytes,
                                     codingData.length,
                                     buffer,
                                     bufferSize,
                                     &numBytesEncrypted);
    NSData *output = [NSData dataWithBytes:buffer length:numBytesEncrypted];
    
    if( result == kCCSuccess )
    {
        // 2. base 64 string encode
        return [output base64EncodedStringWithOptions:0];;
    }
    else
    {
        NSLog(@"Failed DES encrypt...");
        return nil;
    }
}

+ (NSData *) decryptDES:(NSString *)codedStr withKey:(NSString *)enkey isGBKorUTF8:(BOOL)isGBK
{
    // 1. decode base64 string
    NSData *decodedData =
    [[NSData alloc] initWithBase64EncodedString:codedStr
                                        options:NSDataBase64DecodingIgnoreUnknownCharacters];
    
    // 2.1 convert enkey to nsdata type.
    NSData *key = [enkey dataUsingEncoding:NSUTF8StringEncoding];
    
    // 2.2 decryption
    size_t numBytesEncrypted = 0;
    size_t bufferSize = decodedData.length + kCCBlockSizeDES;
    void *buffer_decrypt = malloc(bufferSize);
    CCCryptorStatus result = CCCrypt(kCCDecrypt,
                                     kCCAlgorithmDES,
                                     kCCOptionPKCS7Padding,
                                     key.bytes,
                                     kCCKeySizeDES,
                                     iv,
                                     decodedData.bytes,
                                     decodedData.length,
                                     buffer_decrypt,
                                     bufferSize,
                                     &numBytesEncrypted);
    
    // 2.3
    NSData *output = [NSData dataWithBytes:buffer_decrypt length:numBytesEncrypted];
    free(buffer_decrypt);
    
    // 2.4 convert GBK encoded data to UTF8
    NSString* convertedStr;
    /*
    if (isGBK) {
        NSStringEncoding enc =
        CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        
        convertedStr = [[NSString alloc] initWithData:output encoding:enc];
    }
    else
    {
        convertedStr =
        [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    }*/
    convertedStr =
    [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
    // 2.4
    if( result == kCCSuccess )
    {
        return [convertedStr dataUsingEncoding:NSUTF8StringEncoding];
    }
    else
    {
        NSLog(@"Failed DES decrypt ...");
        return nil;
    }
}

+ (NSString *)formatSeconds:(NSNumber *)timeInSeconds
{
    long sec = [timeInSeconds longValue];
    
    //int days = sec / 86400;
    long hours = sec / 3600;
    int minutes = (sec % 86400) % 3600 / 60;
    int seconds = (sec % 86400) % 3600 % 60;
    
    NSString *timeLast = @"";
    /*if (days) {
        timeLast =
        [timeLast stringByAppendingFormat:@"%d天%d小时%d分%d秒",
         days, hours, minutes, seconds];
    }
    else*/ if (hours)
    {
        timeLast =
        [timeLast stringByAppendingFormat:@"%ld小时%d分%d秒",
         hours, minutes, seconds];
    }
    else if (minutes)
    {
        timeLast =
        [timeLast stringByAppendingFormat:@"%d分%d秒",
         minutes, seconds];
    }
    else
    {
        timeLast =
        [timeLast stringByAppendingFormat:@"%d秒",
         seconds];
    }
    return timeLast;
}

@end
