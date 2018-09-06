//
//  UIView+MBProgressHUD.h
//  LFMBProgressHUDDemo
//
//  Created by WangZhiWei on 16/5/26.
//  Copyright © 2016年 youku. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LFMBProgressHUD;

@interface UIView (LFMBProgressHUDAdditions)


/*!
 	@method
 	@abstract   显示转菊花
 	@param 	animated 是否支持动画
 */
- (void)lf_showHUDAnimated:(BOOL)animated;


/**

 @param animated 是否支持动画
 */
- (void)lf_hideHUDAnimated:(BOOL)animated;

/**
 @abstract  延迟显示动画
 @param animated 是否支持动画
 @param delay  延迟显示动画时间
 */
- (void)lf_showHUDAnimated:(BOOL)animated afterDelay:(NSTimeInterval)delay;



/*!
 	@method
 	@abstract   提示框,屏幕中间位置，支持多行 默认1.2秒消失
  	@param 	message 	消息内容
 	@param 	animated    是否支持动画
 */
- (void)lf_showHUD:(NSString *)message animated:(BOOL)animated ;

/*!
 	@method
 	@abstract   可以设定时间的提示框,屏幕中间位置，支持多行
  	@param 	message 	消息内容
 	@param 	animated 是否支持动画
 	@param 	time 	延迟时间
 */
- (LFMBProgressHUD *)lf_showHUD:(NSString *)message
                       animated:(BOOL)animated
                      hideAfter:(NSTimeInterval)time;



/**
 *  老版本解决键盘弹出时候挡住提示框的一种办法（其实只是由多行变为只支持单行）
 *
 *  @param message 消息内容
 *  @param offsetY 坐标位置
 *  @param animated 是否支持动画
 */

- (void)popupMessage:(NSString*)message offsetY:(CGFloat)offsetY animated:(BOOL)animated;


/*!
 @method
 @param 	message 	消息内容
 @param     image  图片资源
 @param 	animated 是否支持动画
 @param 	time 	延迟时间
 */
- (void)lf_showHUD:(NSString *)message image:(UIImage *)image animated:(BOOL)animated hideAfter:(NSTimeInterval)time;


/*!
 	@method
 	@discussion	删除
 	@param 	animated 删除
 */
- (void)lf_removeAllHUDAnimated:(BOOL)animated;



#pragma mark --过期方法
- (void)lf_showHUDAnimated:(BOOL)animated message:(NSString *)message __attribute__((deprecated("Use lf_showHUD: animated: instead.")));

- (LFMBProgressHUD *)lf_showHUDAnimated:(BOOL)animated message:(NSString *)message
                              dalayTime:(NSTimeInterval)time __attribute__((deprecated("Use - (LFMBProgressHUD *)lf_showHUD: animated: dalay: instead.")));





@end
