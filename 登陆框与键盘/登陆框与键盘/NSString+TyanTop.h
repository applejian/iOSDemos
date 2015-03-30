//
//  NSString+TyanTop.h
//  CDoom
//
//  Created by ChenLi on 14-5-12.
//  Copyright (c) 2014年 HNMDD. All rights reserved.
//

#import <Foundation/Foundation.h>

#define CDOOM_PHONENUM_LENGTH 11

#define CDOOM_PASSWORD_LENGTH_MIN 6
#define CDOOM_PASSWORD_LENGTH_MAX 16

@interface NSString (TyanTop)

+(BOOL) isValidEmail:(NSString *)checkString;

+(BOOL) isValidMobilePhoneNumber:(NSString *)phoneNumberStr
                           error:(NSError **)error;

+(BOOL) isValidPassword:(NSString *)passwordStr
                  error:(NSError **)error;

+(BOOL) isValidNickName:(NSString *)checkingStr
                  error:(NSError **)error;

+(NSString *) encryptDES:(NSData *)codingData withKey:(NSString *)enKey;
+(NSString *) forYunWanEncryptDES:(NSData *)codingData withKey:(NSString *)enKey;   // jason add

+(NSData *) decryptDES:(NSString *)codedStr
               withKey:(NSString *)enkey
           isGBKorUTF8:(BOOL)isGBK;

+(BOOL) isValidVerifyCode:(NSString *)checkingStr
                    error:(NSError **)error;

+ (NSString *)formatSeconds:(NSNumber *)timeInSeconds;

@end
