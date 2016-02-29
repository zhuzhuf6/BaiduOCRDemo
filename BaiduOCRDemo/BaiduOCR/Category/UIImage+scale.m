//
//  UIImage+scale.m
//  ZFProspect2
//
//  Created by 朱敏 on 15/10/13.
//  Copyright © 2015年 com.ZF. All rights reserved.
//

#import "UIImage+scale.h"

@implementation UIImage (scale)
+ (UIImage *) OriginImage:(UIImage *)image scaleToSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);  //size 为CGSize类型，即你所需要的图片尺寸
    
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return scaledImage;
    
}

+ (UIImage *)OriginImage:(UIImage *)image interceptionToFrame:(CGRect)frame {
    UIImage *newImage = [UIImage imageWithCGImage:CGImageCreateWithImageInRect([image CGImage], frame)];
    return newImage;
}
@end
