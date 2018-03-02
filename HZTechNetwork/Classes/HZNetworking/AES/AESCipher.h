//
//  AESCipher.h
//  HZPeopleDeputies
//
//  Created by 武汉一青科技有限公司 on 2018/1/18.
//  Copyright © 2018年 hztech. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AESCipher : NSObject
/** AES加密
 @param content 明文
 @return 密文
 */
+ (NSString *)encryptAES:(NSString *)content;

/** AES解密
 @param content 密文
 @return 明文
 */
+ (NSString *)decryptAES:(NSString *)content;

@end
