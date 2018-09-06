//
//  NSDate+Util.m
//  SFPay
//
//  Created by ssf-2 on 14-11-13.
//  Copyright (c) 2014年 SF. All rights reserved.
//

#import "NSDate+Util.h"

@implementation NSDate (Util)

+ (NSDate *)dateWithString:(NSString *)str format:(NSString *)formating {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formating];
    return [dateFormatter dateFromString:str];
}

+ (NSString *)dateToString:(NSDate *)date format:(NSString *)formating {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formating];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"]];
    return [dateFormatter stringFromDate:date];
}

+ (NSString *)dateWithTimeInterval:(NSTimeInterval)interval format:(NSString *)formating {
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:interval];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formating];
    return [dateFormatter stringFromDate:date];
}

+ (NSTimeInterval)timeIntervalWithString:(NSString *)str format:(NSString *)formating {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:formating];
    NSDate *date = [dateFormatter dateFromString:str];
    return [date timeIntervalSince1970];
}

+ (NSDate *)dateWithStringMuitiform:(NSString *)str {
    NSDate *time = nil;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    time = [dateFormatter dateFromString:str];
    if (time == nil) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd"];
        time = [dateFormatter dateFromString:str];
    }
    if (time == nil) {
        [dateFormatter setDateFormat:@"yyyyMMddHHmmss"];
        time = [dateFormatter dateFromString:str];
    }
    if (time == nil) {
        [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
        time = [dateFormatter dateFromString:str];
    }
    if (time == nil) {
        [dateFormatter setDateFormat:@"yyyyMMdd HH:mm:ss"];
        time = [dateFormatter dateFromString:str];
    }
    if (time == nil) {
        [dateFormatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        time = [dateFormatter dateFromString:str];
    }
    if (time == nil) {
        [dateFormatter setDateFormat:@"MMdd"];
        time = [dateFormatter dateFromString:str];
    }
    return time;
}

+ (NSString *)dateToSpecialTime:(NSDate *)time {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitWeekday |
                         NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;

    NSDate *nowDate = [NSDate date];

    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateStyle:NSDateFormatterMediumStyle];
    [inputFormatter setTimeStyle:NSDateFormatterShortStyle];
    [inputFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];

    NSDateComponents *nowCom = [calendar components:unitFlags fromDate:nowDate];
    NSDateComponents *comCom = [calendar components:unitFlags fromDate:time];

    NSString *returnStr = @"";

    //如果为同一天
    if (([nowCom day] == [comCom day]) && ([nowCom month] == [comCom month]) && ([nowCom year] == [comCom year])) {
        [inputFormatter setDateFormat:@"HH:mm"];
        returnStr = [inputFormatter stringFromDate:time];
    } else if (([nowCom year] == [comCom year]) && ([nowCom day] == [comCom day] -1) && ([nowCom month] == [comCom month])) {
        [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        returnStr = [inputFormatter stringFromDate:time];
    } else if (([nowCom year] == [comCom year])) {
        [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        returnStr = [inputFormatter stringFromDate:time];
    } else {
        [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm"];
        returnStr = [inputFormatter stringFromDate:time];

    }
    return returnStr;
}

+ (NSString *)timeWithSec:(int)totalSeconds format:(NSString *)format {
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;

    if (format.length == 0) {
        return @"00:00:00";
    } else {
        if ([format isEqualToString:@"HH:mm:ss"]) {
            return [NSString stringWithFormat:@"%02d:%02d:%02d", hours, minutes, seconds];
        } else if ([format isEqualToString:@"mm:ss"]) {
            return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
        }
    }
    return @"00:00:00";
}

+ (NSString *)formatTimeString:(NSTimeInterval)timestamp {
    
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    
    NSDate *createDate=[NSDate dateWithTimeIntervalSince1970:timestamp];
    
    NSDate *now = [NSDate date];// 当前时间
    NSCalendar *calendar = [NSCalendar currentCalendar];  // 日历对象（方便比较两个日期之间的差距）
    // NSCalendarUnit枚举代表想获得哪些差值
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSDateComponents *cmps = [calendar components:unit fromDate:createDate toDate:now options:0];// 两日期差值
    
    if ([createDate isThisYear]) { // 今年
        if ([createDate isYesterday]) { // 昨天
            fmt.dateFormat = @"昨天 HH:mm";
            return [fmt stringFromDate:createDate];
        } else if ([createDate isToday]) { // 今天
            if (cmps.hour >= 1) {
                return [NSString stringWithFormat:@"%d小时前", (int)cmps.hour];
            } else if (cmps.minute >= 1) {
                return [NSString stringWithFormat:@"%d分钟前", (int)cmps.minute];
            } else {
                return @"刚刚";
            }
        } else { // 今年的其他日子
            fmt.dateFormat = @"MM-dd HH:mm";
            return [fmt stringFromDate:createDate];
        }
    } else { // 非今年
        fmt.dateFormat = @"yyyy-MM-dd HH:mm";
        return [fmt stringFromDate:createDate];
    }
}

/**
 *  判断某个时间是否为今年
 */
- (BOOL)isThisYear {
    NSCalendar *calendar = [NSCalendar currentCalendar];
    // 获得某个时间的年月日时分秒
    NSDateComponents *dateCmps = [calendar components:NSCalendarUnitYear fromDate:self];
    NSDateComponents *nowCmps = [calendar components:NSCalendarUnitYear fromDate:[NSDate date]];
    return dateCmps.year == nowCmps.year;
}

/**
 *  判断某个时间是否为昨天
 */
- (BOOL)isYesterday {
    NSDate *now = [NSDate date];
    
    // date ==  2014-04-30 10:05:28 --> 2014-04-30 00:00:00
    // now == 2014-05-01 09:22:10 --> 2014-05-01 00:00:00
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    // 2014-04-30
    NSString *dateStr = [fmt stringFromDate:self];
    // 2014-10-18
    NSString *nowStr = [fmt stringFromDate:now];
    
    // 2014-10-30 00:00:00
    NSDate *date = [fmt dateFromString:dateStr];
    // 2014-10-18 00:00:00
    now = [fmt dateFromString:nowStr];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    
    NSCalendarUnit unit = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay;
    NSDateComponents *cmps = [calendar components:unit fromDate:date toDate:now options:0];
    
    return cmps.year == 0 && cmps.month == 0 && cmps.day == 1;
}

/**
 *  判断某个时间是否为今天
 */
- (BOOL)isToday {
    NSDate *now = [NSDate date];
    NSDateFormatter *fmt = [[NSDateFormatter alloc] init];
    fmt.dateFormat = @"yyyy-MM-dd";
    
    NSString *dateStr = [fmt stringFromDate:self];
    NSString *nowStr = [fmt stringFromDate:now];
    
    return [dateStr isEqualToString:nowStr];
}

@end
