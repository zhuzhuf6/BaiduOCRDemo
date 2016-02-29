//
//  UIImage+scale.h
//  ZFProspect2
//
//  Created by 朱敏 on 15/10/13.
//  Copyright © 2015年 com.ZF. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (scale)
/**
 *  对图片进行缩放
 */
+ (UIImage *) OriginImage:(UIImage *)image scaleToSize:(CGSize)size;
/**
 *  截取图片
 */
+ (UIImage *)OriginImage:(UIImage *)image interceptionToFrame:(CGRect)frame;
@end
