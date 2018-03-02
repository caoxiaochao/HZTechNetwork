//
//  HZNetworking.h
//  HZPeopleDeputies
//  基于AFNetworking二次封装的网络请求框架，包含参数AES加密功能
//  Created by 武汉一青科技有限公司 on 2018/3/1.
//  Copyright © 2018年 hztech. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  网络状态
 */
typedef NS_ENUM(NSInteger, HZNetworkStatus) {
    /**
     *  未知网络
     */
    HZNetworkStatusUnknown             = 1 << 0,
    /**
     *  无法连接
     */
    HZNetworkStatusNotReachable        = 1 << 1,
    /**
     *  WWAN网络
     */
    HZNetworkStatusReachableViaWWAN    = 1 << 2,
    /**
     *  WiFi网络
     */
    HZNetworkStatusReachableViaWiFi    = 1 << 3
};

/**
 *  请求任务
 */
typedef NSURLSessionTask HZURLSessionTask;

/**
 *  成功回调
 *
 *  @param responseObject 成功后返回的数据
 */
typedef void(^HZResponseSuccessBlock)(id responseObject);

/**
 *  失败回调
 *
 *  @param error 失败后返回的错误信息
 */
typedef void(^HZResponseFailBlock)(NSError *error);

/**
 *  下载进度
 *
 *  @param bytesRead              已下载的大小
 *  @param totalBytes                总下载大小
 */
typedef void (^HZDownloadProgress)(int64_t bytesRead,
                                   int64_t totalBytes);

/**
 *  下载成功回调
 *
 *  @param url                       下载存放的路径
 */
typedef void(^HZDownloadSuccessBlock)(NSURL *url);


/**
 *  上传进度
 *
 *  @param bytesWritten              已上传的大小
 *  @param totalBytes                总上传大小
 */
typedef void(^HZUploadProgressBlock)(int64_t bytesWritten,
                                     int64_t totalBytes);
/**
 *  多文件上传成功回调
 *
 *  @param responses 成功后返回的数据
 */
typedef void(^HZMultUploadSuccessBlock)(NSArray *responses);

/**
 *  多文件上传失败回调
 *
 *  @param errors 失败后返回的错误信息
 */
typedef void(^HZMultUploadFailBlock)(NSArray *errors);

typedef HZDownloadProgress HZGetProgress;

typedef HZDownloadProgress HZPostProgress;

typedef HZResponseFailBlock HZDownloadFailBlock;

@interface HZNetworking : NSObject

/**
 *  正在运行的网络任务
 *
 *  @return task
 */
+ (NSArray *)currentRunningTasks;


/**
 *  配置请求头
 *
 *  @param httpHeader 请求头
 */
+ (void)configHttpHeader:(NSDictionary *)httpHeader;

/**
 *  取消GET请求
 */
+ (void)cancelRequestWithURL:(NSString *)url;

/**
 *  取消所有请求
 */
+ (void)cancleAllRequest;

/**
 *    设置超时时间
 *
 *  @param timeout 超时时间
 */
+ (void)setupTimeout:(NSTimeInterval)timeout;

/**
 *  GET请求
 *
 *  @param url              请求路径

 *  @param isAESCipher      是否AES加密
 *  @param params           拼接参数
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
// *  @param refresh          是否刷新请求(遇到重复请求，若为YES，则会取消旧的请求，用新的请求，若为NO，则忽略新请求，用旧请求)
// *  @param progressBlock    进度回调
+ (HZURLSessionTask *)getWithUrl:(NSString *)url
//                  refreshRequest:(BOOL)refresh
                     isAESCipher:(BOOL)isAESCipher
                          params:(NSDictionary *)params
//                   progressBlock:(HZGetProgress)progressBlock
                    successBlock:(HZResponseSuccessBlock)successBlock
                       failBlock:(HZResponseFailBlock)failBlock;

/**
 *  POST请求
 *
 *  @param url              请求路径

 *  @param isAESCipher      是否AES加密
 *  @param params           拼接参数
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
//*  @param refresh          解释同上
//*  @param progressBlock    进度回调
+ (HZURLSessionTask *)postWithUrl:(NSString *)url
//                   refreshRequest:(BOOL)refresh
                      isAESCipher:(BOOL)isAESCipher
                           params:(NSDictionary *)params
//                    progressBlock:(HZPostProgress)progressBlock
                     successBlock:(HZResponseSuccessBlock)successBlock
                        failBlock:(HZResponseFailBlock)failBlock;

/**
 *  文件上传
 *
 *  @param url              上传文件接口地址
 *  @param params           拼接参数
 *  @param name             The name to be associated with the specified data. This parameter must not be `nil`.
 *  @param fileName         The filename to be associated with the specified data. This parameter must not be `nil`.
 *  @param mimeType         The MIME type of the specified data. (For example, the MIME type for a JPEG image is image/jpeg.) For a list of valid MIME types, see http://www.iana.org/assignments/media-types/. This parameter must not be `nil`.
 *  @param filePath         上传文件路径
 *  @param isAESCipher      是否AES加密
 *  @param progressBlock    进度回调
 *  @param successBlock     成功回调
 *  @param failBlock        失败回调
 *
 *  @return 返回的对象中可取消请求
 */
+ (HZURLSessionTask *)uploadFileWithUrl:(NSString *)url
                                 params:(NSDictionary *)params
                                   name:(NSString *)name
                               fileName:(NSString *)fileName
                               mimeType:(NSString *)mimeType
                               filePath:(NSString *)filePath
                            isAESCipher:(BOOL)isAESCipher
                          progressBlock:(HZUploadProgressBlock)progressBlock
                           successBlock:(HZResponseSuccessBlock)successBlock
                              failBlock:(HZResponseFailBlock)failBlock;

/**
 *  文件下载
 *
 *  @param url           下载文件接口地址
 *  @param progressBlock 下载进度
 *  @param successBlock  成功回调
 *  @param failBlock     下载回调
 *
 *  @return 返回的对象可取消请求
 */
+ (HZURLSessionTask *)downloadWithUrl:(NSString *)url
                        progressBlock:(HZDownloadProgress)progressBlock
                         successBlock:(HZDownloadSuccessBlock)successBlock
                            failBlock:(HZDownloadFailBlock)failBlock;
@end








