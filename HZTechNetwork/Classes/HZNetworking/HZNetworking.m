//
//  HZNetworking.m
//  HZPeopleDeputies
//
//  Created by 武汉一青科技有限公司 on 2018/3/1.
//  Copyright © 2018年 hztech. All rights reserved.
//

#import "HZNetworking.h"
//#import "AFNetworking.h"
//#import "AFNetworkActivityIndicatorManager.h"
#import "HZNetworking+RequestManager.h"
#import "AESCipher.h"

#if __has_include(<AFNetworking/AFNetworking.h>)
#import <AFNetworking/AFNetworking.h>
#else
#import "AFNetworking.h"
#endif

#if __has_include(<AFNetworking/AFNetworkActivityIndicatorManager.h>)
#import <AFNetworking/AFNetworkActivityIndicatorManager.h>
#else
#import "AFNetworkActivityIndicatorManager.h"
#endif

#define HZ_ERROR_TIP @"网络出现错误，请检查网络连接"

#define HZ_ERROR [NSError errorWithDomain:@"com.hz.HZNetworking.ErrorDomain" code:-999 userInfo:@{ NSLocalizedDescriptionKey:HZ_ERROR_TIP}]

static NSMutableArray   *requestTasksPool;

static NSDictionary     *headers;

static HZNetworkStatus  networkStatus;

static NSTimeInterval   requestTimeout = 20.f;

@implementation HZNetworking
#pragma mark - manager
+ (AFHTTPSessionManager *)manager {
    //请求数据慢的时候，手机的左上角会出现菊花的效果
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    //默认解析模式
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    
    //配置请求序列化
    AFJSONResponseSerializer *serializer = [AFJSONResponseSerializer serializer];
    
    [serializer setRemovesKeysWithNullValues:YES];
    
    manager.requestSerializer.stringEncoding = NSUTF8StringEncoding;
    
    manager.requestSerializer.timeoutInterval = requestTimeout;
    
    for (NSString *key in headers.allKeys) {
        if (headers[key] != nil) {
            [manager.requestSerializer setValue:headers[key] forHTTPHeaderField:key];
        }
    }
    
    //配置响应序列化
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithArray:@[@"application/json",
                                                                              @"text/html",
                                                                              @"text/json",
                                                                              @"text/plain",
                                                                              @"text/javascript",
                                                                              @"text/xml",
                                                                              @"image/*",
                                                                              @"application/octet-stream",
                                                                              @"application/zip"]];
    
    [self checkNetworkStatus];
    
    return manager;
}

#pragma mark - 检查网络
+ (void)checkNetworkStatus {
    AFNetworkReachabilityManager *manager = [AFNetworkReachabilityManager sharedManager];
    
    [manager startMonitoring];
    
    [manager setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        
        switch (status) {
            case AFNetworkReachabilityStatusNotReachable:
                networkStatus = HZNetworkStatusNotReachable;
                break;
            case AFNetworkReachabilityStatusUnknown:
                networkStatus = HZNetworkStatusUnknown;
                break;
            case AFNetworkReachabilityStatusReachableViaWWAN:
                networkStatus = HZNetworkStatusReachableViaWWAN;
                break;
            case AFNetworkReachabilityStatusReachableViaWiFi:
                networkStatus = HZNetworkStatusReachableViaWiFi;
                break;
            default:
                networkStatus = HZNetworkStatusUnknown;
                break;
        }
        
    }];
}

+ (NSMutableArray *)allTasks {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (requestTasksPool == nil) requestTasksPool = [NSMutableArray array];
    });
    
    return requestTasksPool;
}

#pragma mark - 重组AES加密后的参数
+ (NSDictionary *)requestParams:(NSDictionary*)params isAESCipher:(BOOL)isAESCipher
{
    NSDictionary* requestData = params;

    if (isAESCipher) {
        //AES加密
        NSMutableDictionary* restructData = [[NSMutableDictionary alloc]init];
        [params enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
            [restructData setObject:[AESCipher encryptAES:obj] forKey:key];
        }];
        requestData = restructData;
    }
    return requestData;
}

#pragma mark - GET
+ (HZURLSessionTask *)getWithUrl:(NSString *)url
                     isAESCipher:(BOOL)isAESCipher
                          params:(NSDictionary *)params
//                   progressBlock:(HZGetProgress)progressBlock
                    successBlock:(HZResponseSuccessBlock)successBlock
                       failBlock:(HZResponseFailBlock)failBlock {
    //将session拷贝到堆中，block内部才可以获取得到session
    __block HZURLSessionTask *session = nil;
    
    NSDictionary* requestParams = [self requestParams:params isAESCipher:isAESCipher];
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == HZNetworkStatusNotReachable) {
        if (failBlock) failBlock(HZ_ERROR);
        return session;
    }
    
    session = [manager GET:url
                parameters:requestParams
                  progress:^(NSProgress * _Nonnull downloadProgress) {
//                      if (progressBlock) progressBlock(downloadProgress.completedUnitCount,
//                                                       downloadProgress.totalUnitCount);
                      
                  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      if (successBlock) successBlock(responseObject);
                      [[self allTasks] removeObject:session];
                      
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      if (failBlock) failBlock(error);
                      [[self allTasks] removeObject:session];
                      
                  }];
    
//    if ([self haveSameRequestInTasksPool:session] && !refresh) {
//        //取消新请求
//        [session cancel];
//        return session;
//    }else {
        //无论是否有旧请求，先执行取消旧请求，反正都需要刷新请求
        HZURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
//    }
}

#pragma mark - post
+ (HZURLSessionTask *)postWithUrl:(NSString *)url
                      isAESCipher:(BOOL)isAESCipher
                           params:(NSDictionary *)params
//                    progressBlock:(HZPostProgress)progressBlock
                     successBlock:(HZResponseSuccessBlock)successBlock
                        failBlock:(HZResponseFailBlock)failBlock {
    __block HZURLSessionTask *session = nil;
    
    NSDictionary* requestParams = [self requestParams:params isAESCipher:isAESCipher];
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == HZNetworkStatusNotReachable) {
        if (failBlock) failBlock(HZ_ERROR);
        return session;
    }
    
    session = [manager POST:url
                 parameters:requestParams
                   progress:^(NSProgress * _Nonnull uploadProgress) {
//                       if (progressBlock) progressBlock(uploadProgress.completedUnitCount,
//                                                        uploadProgress.totalUnitCount);
//
                   } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                       if (successBlock) successBlock(responseObject);
                       
                       if ([[self allTasks] containsObject:session]) {
                           [[self allTasks] removeObject:session];
                       }
                       
                   } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                       if (failBlock) failBlock(error);
                       [[self allTasks] removeObject:session];
                       
                   }];
    
    
//    if ([self haveSameRequestInTasksPool:session] && !refresh) {
//        [session cancel];
//        return session;
//    }else {
        //无论是否有旧请求，先执行取消旧请求，反正都需要刷新请求
        HZURLSessionTask *oldTask = [self cancleSameRequestInTasksPool:session];
        if (oldTask) [[self allTasks] removeObject:oldTask];
        if (session) [[self allTasks] addObject:session];
        [session resume];
        return session;
//    }
}

#pragma mark - 文件上传
+ (HZURLSessionTask *)uploadFileWithUrl:(NSString *)url
                                 params:(NSDictionary *)params
                                   name:(NSString *)name
                               fileName:(NSString *)fileName
                               mimeType:(NSString *)mimeType
                               filePath:(NSString *)filePath
                            isAESCipher:(BOOL)isAESCipher
                          progressBlock:(HZUploadProgressBlock)progressBlock
                           successBlock:(HZResponseSuccessBlock)successBlock
                              failBlock:(HZResponseFailBlock)failBlock {
    __block HZURLSessionTask *session = nil;
    
    NSDictionary* requestParams = [self requestParams:params isAESCipher:isAESCipher];
    
    AFHTTPSessionManager *manager = [self manager];
    
    if (networkStatus == HZNetworkStatusNotReachable) {
        if (failBlock) failBlock(HZ_ERROR);
        return session;
    }
    
    session = [manager POST:url
                 parameters:nil
  constructingBodyWithBlock:^(id<AFMultipartFormData>  _Nonnull formData) {
      
      [requestParams enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
          [formData appendPartWithFormData:obj name:key];
      }];
      
      if (filePath.length>0) {
          NSData *data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:nil];
          [formData appendPartWithFileData:data name:name fileName:fileName mimeType:mimeType.length>0?mimeType:@""];
      }
  } progress:^(NSProgress * _Nonnull uploadProgress) {
      if (progressBlock) progressBlock (uploadProgress.completedUnitCount,uploadProgress.totalUnitCount);
  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
      if (successBlock) successBlock(responseObject);
      [[self allTasks] removeObject:session];
      
  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
      if (failBlock) failBlock(error);
      [[self allTasks] removeObject:session];
      
  }];
    
    [session resume];
    
    if (session) [[self allTasks] addObject:session];
    
    return session;
}

#pragma mark - 下载
+ (HZURLSessionTask *)downloadWithUrl:(NSString *)url
                        progressBlock:(HZDownloadProgress)progressBlock
                         successBlock:(HZDownloadSuccessBlock)successBlock
                            failBlock:(HZDownloadFailBlock)failBlock {
    __block HZURLSessionTask *session = nil;
   
    AFHTTPSessionManager *manager = [self manager];
    //响应内容序列化为二进制
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    session = [manager GET:url
                parameters:nil
                  progress:^(NSProgress * _Nonnull downloadProgress) {
                      if (progressBlock) progressBlock(downloadProgress.completedUnitCount, downloadProgress.totalUnitCount);
                      
                  } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
                      if (successBlock) {
                          successBlock(responseObject);
                      }
                      
                  } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
                      if (failBlock) {
                          failBlock (error);
                      }
                  }];
    
    [session resume];
    
    if (session) [[self allTasks] addObject:session];
    
    return session;
    
}

#pragma mark - other method
+ (void)setupTimeout:(NSTimeInterval)timeout {
    requestTimeout = timeout;
}

+ (void)cancleAllRequest {
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(HZURLSessionTask  *_Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[HZURLSessionTask class]]) {
                [obj cancel];
            }
        }];
        [[self allTasks] removeAllObjects];
    }
}

+ (void)cancelRequestWithURL:(NSString *)url {
    if (!url) return;
    @synchronized (self) {
        [[self allTasks] enumerateObjectsUsingBlock:^(HZURLSessionTask * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[HZURLSessionTask class]]) {
                if ([obj.currentRequest.URL.absoluteString hasSuffix:url]) {
                    [obj cancel];
                    *stop = YES;
                }
            }
        }];
    }
}

+ (void)configHttpHeader:(NSDictionary *)httpHeader {
    headers = httpHeader;
}

+ (NSArray *)currentRunningTasks {
    return [[self allTasks] copy];
}


@end
