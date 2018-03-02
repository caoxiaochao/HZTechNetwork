//
//  AESCipher.m
//  HZPeopleDeputies
//
//  Created by 武汉一青科技有限公司 on 2018/1/18.
//  Copyright © 2018年 hztech. All rights reserved.
//

#import "AESCipher.h"
#import <CommonCrypto/CommonCryptor.h>

NSString *const kInitVector = @"9f1-f7610e523a07";

size_t const kKeySize = kCCKeySizeAES256;

#define key @"86d78f88613545e18b5edb97dba144e1"   //密钥

@implementation AESCipher

#pragma mark - 加密
+ (NSString *)encryptAES:(NSString *)content{
    NSData *contentData = [content dataUsingEncoding:NSUTF8StringEncoding];
    NSUInteger dataLength = contentData.length;
    
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    size_t encryptSize = dataLength + kCCBlockSizeAES128;
    void *encryptedBytes = malloc(encryptSize);
    size_t actualOutSize = 0;
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt,
                                          kCCAlgorithmAES128,
                                          kCCOptionPKCS7Padding| kCCOptionECBMode,
                                          keyPtr,
                                          kKeySize,
                                          NULL,
                                          contentData.bytes,
                                          dataLength,
                                          encryptedBytes,
                                          encryptSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        return [self symbolHandle:[[NSData dataWithBytesNoCopy:encryptedBytes length:actualOutSize] base64EncodedStringWithOptions:NSDataBase64EncodingEndLineWithLineFeed] isDecrypt:NO];
    }
    free(encryptedBytes);
    return nil;
}

#pragma mark - 解密
+ (NSString *)decryptAES:(NSString *)content{
    content = [self symbolHandle:content isDecrypt:YES];
    NSData *contentData = [[NSData alloc] initWithBase64EncodedString:content options:NSDataBase64DecodingIgnoreUnknownCharacters];
    NSUInteger dataLength = contentData.length;
    
    char keyPtr[kKeySize + 1];
    memset(keyPtr, 0, sizeof(keyPtr));
    [key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
    
    size_t decryptSize = dataLength + kCCBlockSizeAES128;
    void *decryptedBytes = malloc(decryptSize);
    size_t actualOutSize = 0;
    
    NSData *initVector = [kInitVector dataUsingEncoding:NSUTF8StringEncoding];
    
    CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt,
                                          kCCAlgorithmAES,
                                          kCCOptionPKCS7Padding| kCCOptionECBMode,
                                          keyPtr,
                                          kKeySize,
                                          initVector.bytes,
                                          contentData.bytes,
                                          dataLength,
                                          decryptedBytes,
                                          decryptSize,
                                          &actualOutSize);
    
    if (cryptStatus == kCCSuccess) {
        
        return [[NSString alloc] initWithData:[NSData dataWithBytesNoCopy:decryptedBytes length:actualOutSize] encoding:NSUTF8StringEncoding];
    }
    free(decryptedBytes);
    return nil;
}

/**
  处理特殊符号
  @param str 明文密文
  @param isDecrypt true解密 false加密
  @return 处理后的字符串
 */
+(NSString*)symbolHandle:(NSString*)str isDecrypt:(BOOL)isDecrypt
{
    if (isDecrypt)
    {
        //解密
        str = [str stringByReplacingOccurrencesOfString:@"-" withString:@"+"];
        str = [str stringByReplacingOccurrencesOfString:@"." withString:@"/"];
        str = [str stringByReplacingOccurrencesOfString:@"*" withString:@"="];
        return str;
    }
    else
    {
        //加密
        str = [str stringByReplacingOccurrencesOfString:@"+" withString:@"-"];
        str = [str stringByReplacingOccurrencesOfString:@"/" withString:@"."];
        str = [str stringByReplacingOccurrencesOfString:@"=" withString:@"*"];
        return str;
    }
}

@end
