//
//  NSDate+Util.h
//  SFPay
//
//  Created by ssf-2 on 14-11-13.
//  Copyright (c) 2014年 SF. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDate (Util)

/**
 *	@brief	从NSString转成NSDate
 *
 *	@param  str     NSString格式日期
 *	@param  formating       格式字符串
 *
 *	@return	NSDate格式日期
 */
+ (NSDate *)dateWithString:(NSString *)str format:(NSString *)formating;


/**
 *	@brief	从NSDate转成NSString
 *
 *	@param  date    NSDate格式日期
 *	@param  formating       格式字符串
 *
 *	@return	NSString格式日期
 */
+ (NSString *)dateToString:(NSDate *)date format:(NSString *)formating;


/**
 *	@brief	从时间戳转到NSString
 *
 *	@param  interval        到1970年1月1日凌晨的秒数
 *	@param  formating       格式字符串
 *
 *	@return	NSString格式日期
 */
+ (NSString *)dateWithTimeInterval:(NSTimeInterval)interval format:(NSString *)formating;

/**
 *	@brief	从NSString转到时间戳
 *
 *	@param  str     NSString格式日期
 *	@param  formating       格式字符串
 *
 *	@return	到1970年1月1日凌晨的秒数
 */
+ (NSTimeInterval)timeIntervalWithString:(NSString *)str format:(NSString *)formating;


/**
 *	@brief	从NSString转成NSDate 支持多种格式 1、yyyyMMddHHmmss 2、yyyy/MM/dd HH:mm:ss 3、yyyy-MM-dd HH:mm:ss 4、yyyyMMdd HH:mm:ss
 *
 *	@param  str     NSString格式日期
 *
 *	@return	NSDate格式日期
 */
+ (NSDate *)dateWithStringMuitiform:(NSString *)str;

/**
 *	@brief	将时间转换成特殊的格式 消息模式
 *
 *	@param  time    NSdate时间格式
 *
 *	@return	NSString时间格式
 */
+ (NSString *)dateToSpecialTime:(NSDate *)time;

/**
 *	@brief	将秒转换成时间格式 支持的格式：HH:mm:ss  mm:ss 两种
 *
 *	@param  totalSeconds    总秒数
 *	@param  format  格式字符串
 *
 *	@return	NSString时间格式
 */
+ (NSString *)timeWithSec:(int)totalSeconds format:(NSString *)format;


//格式化输出时间
+ (NSString *)formatTimeString:(NSTimeInterval)timestamp;


@end
