//
//  HZNetworking+RequestManager.h
//  HZPeopleDeputies
//
//  Created by 武汉一青科技有限公司 on 2018/3/1.
//  Copyright © 2018年 hztech. All rights reserved.
//

#import "HZNetworking.h"

@interface HZNetworking (RequestManager)
/**
 *  判断网络请求池中是否有相同的请求
 *
 *  @param task 网络请求任务
 *
 *  @return bool
 */
+ (BOOL)haveSameRequestInTasksPool:(HZURLSessionTask *)task;

/**
 *  如果有旧请求则取消旧请求
 *
 *  @param task 新请求
 *
 *  @return 旧请求
 */
+ (HZURLSessionTask *)cancleSameRequestInTasksPool:(HZURLSessionTask *)task;
@end
