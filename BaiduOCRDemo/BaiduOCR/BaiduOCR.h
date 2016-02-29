//
//  BaiduOCR.h
//  BaiduOCRDemo
//
//  Created by 朱敏 on 16/2/29.
//  Copyright © 2016年 Arron Zhu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef void(^ORCResults)(NSError *error, NSData *data);

@interface BaiduOCR : NSObject
+ (void)uploadRecognitionWithImage:(UIImage *)uploadImage andCompletion:(ORCResults)completion;

@end
