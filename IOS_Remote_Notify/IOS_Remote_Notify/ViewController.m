//
//  ViewController.m
//  IOS_Remote_Notify
//
//  Created by zhangyj on 16/3/18.
//  Copyright © 2016年 xitong. All rights reserved.
//
/*
 // Notification requests that are waiting for their trigger to fire
 //获取未送达的所有消息列表
 - (void)getPendingNotificationRequestsWithCompletionHandler:(void(^)(NSArray<UNNotificationRequest *> *requests))completionHandler;
 //删除所有未送达的特定id的消息
 - (void)removePendingNotificationRequestsWithIdentifiers:(NSArray<NSString *> *)identifiers;
 //删除所有未送达的消息
 - (void)removeAllPendingNotificationRequests;
 
 // Notifications that have been delivered and remain in Notification Center. Notifiations triggered by location cannot be retrieved, but can be removed.
 //获取已送达的所有消息列表
 - (void)getDeliveredNotificationsWithCompletionHandler:(void(^)(NSArray<UNNotification *> *notifications))completionHandler __TVOS_PROHIBITED;
 //删除所有已送达的特定id的消息
 - (void)removeDeliveredNotificationsWithIdentifiers:(NSArray<NSString *> *)identifiers __TVOS_PROHIBITED;
 //删除所有已送达的消息
 - (void)removeAllDeliveredNotifications __TVOS_PROHIBITED;
 */
#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createLocalNotifyIOS10];
    
}

- (void)createLocalNotifyIOS10 {
    /* 本地推送
     1. 创建一个触发器（trigger）
     2. 创建推送的内容（UNMutableNotificationContent）
     3. 创建推送请求（UNNotificationRequest）
     4. 推送请求添加到推送管理中心（UNUserNotificationCenter）中
     */
    
    //一段时间后触发（定时推送）
    UNTimeIntervalNotificationTrigger *timeTrigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:50 repeats:NO];
    
    
    //在每周一的16点3分提醒（定期推送）
    NSDateComponents *components = [[NSDateComponents alloc] init];
    components.weekday = 2;
    components.hour = 16;
    components.minute = 3;
    // components 日期
    UNCalendarNotificationTrigger *calendarTrigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:YES];
    
    
    // 创建位置信息（定点推送）
    CLLocationCoordinate2D center1 = CLLocationCoordinate2DMake(39.788857, 116.5559392);
    CLCircularRegion *region = [[CLCircularRegion alloc] initWithCenter:center1 radius:500 identifier:@"经海五路"];
    region.notifyOnEntry = YES;
    region.notifyOnExit = YES;
    // region 位置信息 repeats 是否重复 （CLRegion 可以是地理位置信息）
    UNLocationNotificationTrigger *locationTrigger = [UNLocationNotificationTrigger triggerWithRegion:region repeats:YES];
    
    
    
    // 创建通知内容 UNMutableNotificationContent, 注意不是 UNNotificationContent ,此对象为不可变对象。
    UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
    content.title = @"时间提醒 - title";
    content.subtitle = [NSString stringWithFormat:@"装逼大会竞选时间提醒 - subtitle"];
    content.body = @"装逼大会总决赛时间到，欢迎你参加总决赛！希望你一统X界 - body";
    content.badge = @666;
    content.sound = [UNNotificationSound defaultSound];
    content.userInfo = @{@"key1":@"value1",@"key2":@"value2"};
    
    
    //创建推送请求
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"myRequest" content:content trigger:calendarTrigger];
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    [center addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        if (!error) {
            //你自己的需求例如下面：
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"本地通知" message:@"成功添加推送" preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
            [alert addAction:cancelAction];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
    }];
}


@end
