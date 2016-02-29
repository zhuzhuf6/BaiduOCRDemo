//
//  BaiduOCR.m
//  BaiduOCRDemo
//
//  Created by 朱敏 on 16/2/29.
//  Copyright © 2016年 Arron Zhu. All rights reserved.
//

#import "BaiduOCR.h"
#import "GTMBase64.h"

static NSString *const BAIDUOCR_URL = @"http://apis.baidu.com/apistore/idlocr/ocr";
// 使用前必须使用自己的百度appkey
static NSString *const BAIDUOCR_API_KEY = @"";
static NSString *const BAIDUOCR_CONTENT_TYPE = @"application/x-www-form-urlencoded";

@implementation BaiduOCR
+ (void)uploadRecognitionWithImage:(UIImage *)uploadImage andCompletion:(ORCResults)completion {
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL:[NSURL URLWithString:BAIDUOCR_URL] cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod:@"POST"];
    [request addValue:BAIDUOCR_API_KEY forHTTPHeaderField: @"apikey"];
    [request addValue:BAIDUOCR_CONTENT_TYPE forHTTPHeaderField: @"Content-Type"];
    
    //*****************************    设置请求体    ****************************************//
    NSString *httpArg = @"";
    httpArg = [httpArg stringByAppendingString:@"fromdevice=iPhone"];
    httpArg = [httpArg stringByAppendingString:@"&imagetype=1"];
    httpArg = [httpArg stringByAppendingString:@"&clientip=10.10.10.0"];
    httpArg = [httpArg stringByAppendingString:@"&detecttype=LocateRecognize"];
    httpArg = [httpArg stringByAppendingString:@"&languagetype=CHN_ENG"];
    
    NSData *imagedata = UIImageJPEGRepresentation(uploadImage, 1);
    NSString *image = [[NSString alloc] initWithData:[GTMBase64 encodeData:imagedata] encoding:NSUTF8StringEncoding];
    
    // urlencode
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                                              (CFStringRef)image,
                                                              NULL,
                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                              kCFStringEncodingUTF8));
    
    httpArg = [httpArg stringByAppendingString:@"&image="];
    httpArg = [httpArg stringByAppendingString:encodedString];
    
    NSData *data = [httpArg dataUsingEncoding:NSUTF8StringEncoding];
    
    [request setHTTPBody: data];
    
    //*****************************    end    ****************************************//
    __block typeof(completion) weakCompletion = completion;
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [[NSOperationQueue alloc] init]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               return weakCompletion(error, data);
                               
    }];

}
@end
