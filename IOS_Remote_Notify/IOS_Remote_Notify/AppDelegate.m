//
//  AppDelegate.m
//  IOS_Remote_Notify
//
//  Created by zhangyj on 16/3/18.
//  Copyright © 2016年 xitong. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate () <NSURLSessionDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    NSLog(@"launchOptions========%@,%@",launchOptions,launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey]);
    NSString *file = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0] stringByAppendingPathComponent:@"push.plist"];
    remove(file.UTF8String);
    [launchOptions writeToFile:file atomically:YES];
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    CGFloat version = [[UIDevice currentDevice] systemVersion].doubleValue;
    if (version >= 8.0) {
        UIMutableUserNotificationAction *mAct = [[UIMutableUserNotificationAction alloc]init];
        mAct.identifier = @"action";//按钮的标示
        mAct.title=@"Accept";//按钮的标题
        mAct.activationMode = UIUserNotificationActivationModeForeground;//当点击的时候启动程序
        mAct.destructive = YES;
        mAct.authenticationRequired = YES;
        
        UIMutableUserNotificationAction *mAct2 = [[UIMutableUserNotificationAction alloc]init];
        mAct2.identifier = @"action2";//按钮的标示
        mAct2.title=@"Reject";//按钮的标题
        mAct2.activationMode = UIUserNotificationActivationModeBackground;//当点击的时候不启动程序
        mAct2.authenticationRequired = NO;//需要解锁才能处理，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略
        mAct2.destructive = NO;
        
        UIMutableUserNotificationCategory *categorys = [[UIMutableUserNotificationCategory alloc] init];
        categorys.identifier = @"alert";//这组动作的唯一标示,推送通知的时候也是根据这个来区分
        [categorys setActions:@[mAct,mAct2] forContext:UIUserNotificationActionContextMinimal];
        
        UIUserNotificationSettings *notifySet = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:[NSSet setWithObject:categorys]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notifySet];
    }else {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert];
    }
    return YES;
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{
    NSLog(@"handleActionWithIdentifier:%@,userInfo:%@,responseInfo:%@",identifier,userInfo,responseInfo);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    completionHandler();
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    NSLog(@"handleActionWithIdentifier:%@,userInfo:%@",identifier,userInfo);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    completionHandler();
}

//ios7
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
//    if (application.applicationState == UIApplicationStateBackground) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        NSLog(@"ReceiveRemoteNotification userInfo---------%@",userInfo);
//    }
}

//ios8
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
//    if (application.applicationState == UIApplicationStateBackground) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        NSLog(@"ReceiveRemoteNotification userInfo---------%@",userInfo);
        completionHandler(UIBackgroundFetchResultNewData);
//    }
}


- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    [application registerForRemoteNotifications];
}

//注册成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
//    devicetoken
    NSString *token = [self transformDeviceToken:deviceToken];
    
    NSLog(@"deviceToken----------%@",token);
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //发送到自己的服务器
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://kkchat.wolianxi.com/client/user/regtoken"]];
    mRequest.HTTPMethod = @"POST";
    [mRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSDictionary *mapData = @{@"deviceToken" : token};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:nil];
    [mRequest setHTTPBody:postData];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:mRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"NSURLSessionDataTask========%@",error);
    }];
    [task resume];
}

- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

- (NSString *)transformDeviceToken:(NSData *)deviceToken {
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    return token;
}

@end
