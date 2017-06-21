//
//  ViewController.m
//  TestDemo
//
//  Created by kenen on 2017/6/20.
//  Copyright © 2017年 kenen. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()<NSURLSessionDataDelegate>//这个是请求数据的代理

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.

    //请求URL
    [self requestURL];
    
}

//请求URL
- (void)requestURL {
    
    //设置请求的URL(注意网址里面不要加中文字符,如果不放心可以用注释这个)
    NSString *urlStr = @"这里是你要请求的网址";
    //这里是将urlStr转换成了标准的网址
    //NSURL *url = [NSURL URLWithString:[urlStr stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURL *url = [NSURL URLWithString:urlStr];
    
    //创建请求对象,这里是GET请求,NSURLRequest默认是GET请求,NSURLMutableRequest是POST请求
    NSURLRequest *request = [NSURLRequest requestWithURL:url];

    //POST请求这样写,就这个地方不一样,其余全部一样
//    NSMutableURLRequest *request =[NSMutableURLRequest requestWithURL:url];
//    request.HTTPMethod = @"POST";
//    NSString *token = @"这就是token";//参数
//    NSString *user_id = @"这就是user_id";//参数
//    NSString *args = [NSString stringWithFormat:@"token=%@&user_id=%@",token,user_id];
//    request.HTTPBody = [args dataUsingEncoding:NSUTF8StringEncoding];
    
    
    //创建会话对象,并设置代理
     /*
      第一个参数：会话对象的配置信息,defaultSessionConfiguration表示默认配置
     NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
     config.timeoutIntervalForRequest = 10;//超时时间
     config.allowsCellularAccess = YES;//是否允许使用蜂窝网络(后台传输不适用)
     */
    /*
     第二个参数：谁成为代理，此处为控制器本身即self
     */
    /*
     第三个参数：队列，该队列决定代理方法在哪个线程中调用，可以传主队列|非主队列;
     [NSOperationQueue mainQueue]   主队列：   代理方法在主线程中调用
     [[NSOperationQueue alloc]init] 非主队列： 代理方法在子线程中调用
     */
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration] delegate:self delegateQueue:[NSOperationQueue mainQueue]];
    
    
    //这是普通的GET和POST 数据请求(将session和request传到下级)
    [self dataSession:session withRequest:request];
    
    //上传文件(将session和request传到下级)
    [self fileUploadSession:session withRequest:request];
    
}

/*************普通的GET和POST 数据请求****************普通的GET和POST 数据请求*********************/
- (void)dataSession:(NSURLSession *)session withRequest:(NSURLRequest *)request {
    
    // 会话创建任务
    NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
        if (!error) {
            //解析JSON
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
            NSLog(@"%@", dic);
        } else {
            NSLog(@"error is %@", error.localizedDescription);
        }
        
    }];
    
    //执行任务
    [dataTask resume];
}


#pragma mark ---NSURLSessionDataDelegate(普通GET和POST 数据请求代理)
//接收到服务器响应的时候调用该方法
-(void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveResponse:(NSURLResponse *)response completionHandler:(void (^)(NSURLSessionResponseDisposition))completionHandler {
    
    NSLog(@"%@", response);
    
    //注意：需要使用completionHandler回调告诉系统应该如何处理服务器返回的数据
    //默认是取消的
    /*
        NSURLSessionResponseCancel = 0,         默认的处理方式，取消
        NSURLSessionResponseAllow = 1,          接收服务器返回的数据
        NSURLSessionResponseBecomeDownload = 2, 变成一个下载请求
        NSURLSessionResponseBecomeStream        变成一个流
    */
    completionHandler(NSURLSessionResponseAllow);
    
}

//接收到服务器返回数据会调用该方法,可能调用多次
- (void)URLSession:(NSURLSession *)session dataTask:(NSURLSessionDataTask *)dataTask didReceiveData:(NSData *)data {
    
    NSLog(@"%@", data);
    
    //拼接服务器返回的数据
    //[self.data appendData:data];
    
}


/*************上传文件****************上传文件**************上传文件*************上传文件************/
- (void)fileUploadSession:(NSURLSession *)session withRequest:(NSURLRequest *)request {
    
    //在NSURLSession中,文件上传方式主要有以下两种
    //第一种(无参)
    NSURLSessionUploadTask *uploadTask_diyi =
    [[NSURLSession sharedSession] uploadTaskWithRequest:request
                                               fromFile:[NSURL URLWithString:@"这个是文件路径"]
                                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                                          if (error == nil) {
                                              //解析JSON
                                              NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                                              NSLog(@"%@", dic);
                                          }else {
                                              NSLog(@"%@", error);
                                              
                                          }
                                      }];
    
    //第二种(安全,大部分用的就是这样的,传参的)
    NSURLSessionUploadTask *uploadTask =
    [[NSURLSession sharedSession] uploadTaskWithRequest:request
                               fromData:[NSData dataWithContentsOfFile:@"这是参数"]
                      completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
                          if (error == nil) {
                              //解析JSON
                              NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:nil];
                              NSLog(@"%@", dic);
                          }else {
                              NSLog(@"%@", error);
                              
                          }
                      }];
    
    //执行任务
    [uploadTask resume];
    
}


#pragma maek---数据请求,文件上传,文件下载通用的方法
//任务完成时候(成功或者失败)的时候都会调用该方法,如果请求失败则error有值
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error {
    
    if (error == nil) {
        NSLog(@"%@", session);
    }else {
        NSLog(@"%@", error);
        // 保存恢复数据(断点下载)
        NSLog(@"%@", error.userInfo[NSURLSessionDownloadTaskResumeData]);
    }
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
