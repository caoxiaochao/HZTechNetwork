//
//  HZTechViewController.m
//  HZTechNetwork
//
//  Created by ccly080518@163.com on 03/02/2018.
//  Copyright (c) 2018 ccly080518@163.com. All rights reserved.
//

#import "HZTechViewController.h"
#import "HZNetworking.h"
@interface HZTechViewController ()

@end

@implementation HZTechViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    [HZNetworking postWithUrl:@"http://news-at.zhihu.com/api/4/news/latest" isAESCipher:NO params:nil successBlock:^(id responseObject) {
        NSLog(@"%@",responseObject);
    } failBlock:^(NSError *error) {
        NSLog(@"%@",error);
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
