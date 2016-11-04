//
//  AppDelegate.m
//  IOS_Remote_Notify
//
//  Created by zhangyj on 16/3/18.
//  Copyright © 2016年 xitong. All rights reserved.
//

//http://www.jianshu.com/p/c58f8322a278
//http://www.jianshu.com/p/81c6bd16c7ac

#import "AppDelegate.h"

#ifdef NSFoundationVersionNumber_iOS_9_x_Max //ios10之后添加的，所以可以判断有无来判断是否包含此框架
#import <UserNotifications/UserNotifications.h>
#endif

#define version ([[UIDevice currentDevice] systemVersion].doubleValue)

@interface AppDelegate () <NSURLSessionDelegate, UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate



- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    //申请通知权限
    [self replyPushNotificationAuthorization:application];
    
    return YES;
}

#pragma mark: iOS9以上iOS10以下收到用户点击
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void(^)())completionHandler
{
    NSLog(@"handleActionWithIdentifier:%@,userInfo:%@,responseInfo:%@",identifier,userInfo,responseInfo);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    completionHandler();
}

#pragma mark: iOS8以上iOS9以下收到用户点击
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler
{
    NSLog(@"handleActionWithIdentifier:%@,userInfo:%@",identifier,userInfo);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    completionHandler();
}

#pragma mark: iOS7以下收到通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(nonnull NSDictionary *)userInfo {
//    if (application.applicationState == UIApplicationStateBackground) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        NSLog(@"ReceiveRemoteNotification userInfo---------%@",userInfo);
//    }
}

#pragma mark: iOS7以上iOS10以下收到通知
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(nonnull void (^)(UIBackgroundFetchResult))completionHandler
{
//    if (application.applicationState == UIApplicationStateBackground) {
        [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
        NSLog(@"ReceiveRemoteNotification userInfo---------%@",userInfo);
        completionHandler(UIBackgroundFetchResultNewData);
//    }
}

#pragma mark: 成功获取权限
- (void)application:(UIApplication *)application didRegisterUserNotificationSettings:(UIUserNotificationSettings *)notificationSettings {
    //获取devicetoken
    [application registerForRemoteNotifications];
}

#pragma mark: 注册成功
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    //get devicetoken
    NSString *token = [self transformDeviceToken:deviceToken];
    NSLog(@"deviceToken----------%@",token);
    
    //save devicetoken
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"deviceToken"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    //send devicetoken
    [self sendDeviceToken:token];
}

#pragma mark: 注册失败
- (void)application:(UIApplication *)app didFailToRegisterForRemoteNotificationsWithError:(NSError *)err {
    NSLog(@"Error in registration. Error: %@", err);
}

#pragma mark: 生成devicetoken
- (NSString *)transformDeviceToken:(NSData *)deviceToken {
    NSString *token = [NSString stringWithFormat:@"%@", deviceToken];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@"<" withString:@""];
    token = [token stringByReplacingOccurrencesOfString:@">" withString:@""];
    return token;
}

#pragma mark: 发送devicetoken到服务器
- (void)sendDeviceToken:(NSString *)deviceToken {
    //发送到自己的服务器
    NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:self delegateQueue:nil];
    NSMutableURLRequest *mRequest = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:@"http://kkchat.wolianxi.com/client/user/regtoken"]];
    mRequest.HTTPMethod = @"POST";
    [mRequest addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [mRequest addValue:@"application/json" forHTTPHeaderField:@"Accept"];
    NSDictionary *mapData = @{@"deviceToken" : deviceToken};
    NSData *postData = [NSJSONSerialization dataWithJSONObject:mapData options:0 error:nil];
    [mRequest setHTTPBody:postData];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:mRequest completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSLog(@"NSURLSessionDataTask========%@",error);
    }];
    [task resume];
}

#pragma mark: 申请通知权限
- (void)replyPushNotificationAuthorization:(UIApplication *)application {
    if (version >= 10.0) {
        //>ios10
        
        // The UNUserNotificationCenter for the current application
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        //监听通知的接收与点击事件
        center.delegate = self;
        
        //添加按钮
        [self addCategoryForIOS10];
        
        //向用户请求权限
        [center requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            if (!error && granted) {
                NSLog(@"用户点击允许，注册成功");
                
                //注册获取devicetoken
                [application registerForRemoteNotifications];
                
            }else {
                NSLog(@"用户点击不允许，注册失败");
            }
        }];
        
        // 可以通过 getNotificationSettingsWithCompletionHandler 获取权限设置
        //之前注册推送服务，用户点击了同意还是不同意，以及用户之后又做了怎样的更改我们都无从得知，现在 apple 开放了这个 API，我们可以直接获取到用户的设定信息了。注意UNNotificationSettings是只读对象哦，不能直接修改！
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            NSLog(@"========%@",settings);
        }];
        
    } else if (version >= 8.0 && version < 10.0) {
        //ios8-<ios10
        
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
        
        //iOS9可以添加输入框
        
        UIUserNotificationSettings *notifySet = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:[NSSet setWithObject:categorys]];
        [[UIApplication sharedApplication] registerUserNotificationSettings:notifySet];
        
    } else {
        //<ios8
        
        [application registerForRemoteNotificationTypes:UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
    }
}

#pragma mark: iOS10添加交互按钮
- (void)addCategoryForIOS10 {
    
    UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
    //点击类Action
    UNNotificationAction *joinAction = [UNNotificationAction actionWithIdentifier:@"action.join" title:@"接收邀请" options:UNNotificationActionOptionAuthenticationRequired];//解锁
    
    UNNotificationAction *lookAction = [UNNotificationAction actionWithIdentifier:@"action.look" title:@"查看邀请" options:UNNotificationActionOptionForeground];//打开应用
    
    UNNotificationAction *cancelAction = [UNNotificationAction actionWithIdentifier:@"action.cancel" title:@"取消" options:UNNotificationActionOptionDestructive];//取消
    
    //输入框类Action
    UNTextInputNotificationAction *inputAction = [UNTextInputNotificationAction actionWithIdentifier:@"action.input" title:@"输入" options:UNNotificationActionOptionForeground textInputButtonTitle:@"发送" textInputPlaceholder:@"占位文字"];
    
    /*
     intentIdentifiers 意图标识符 可在 <Intents/INIntentIdentifiers.h> 中查看，主要是针对电话、carplay 等开放的 API
     options 通知选项 枚举类型 也是为了支持 carplay
     远端推送Remote Notification一定要保证里面包含category键值对一致
     */
    UNNotificationCategory *notificationCategory = [UNNotificationCategory categoryWithIdentifier:@"alert" actions:@[lookAction, joinAction, cancelAction, inputAction] intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
    
    [center setNotificationCategories:[NSSet setWithObject:notificationCategory]];
}

#pragma mark: iOS10 收到通知（本地和远端) UNUserNotificationCenterDelegate

#pragma mark: App处于前台即将接收通知时
- (void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    //收到推送的请求
    UNNotificationRequest *request = notification.request;
    
    //收到推送的内容
    UNNotificationContent *content = request.content;
    
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    
    //收到推送消息的角标
    NSNumber *badge = content.badge;
    
    //收到推送消息body
    NSString *body = content.body;
    
    //推送消息的声音
    UNNotificationSound *sound = content.sound;
    
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    
    // 推送消息的标题
    NSString *title = content.title;
    
    if([notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@",userInfo);
        
    }else {
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    // 需要执行这个方法，选择是否提醒用户，有Badge、Sound、Alert三种类型可以设置
    completionHandler(UNNotificationPresentationOptionBadge|
                      UNNotificationPresentationOptionSound|
                      UNNotificationPresentationOptionAlert);
    //不提醒，或者不执行completionHandler（没试，不晓得）
//    completionHandler(UNNotificationPresentationOptionNone);
}

#pragma mark: App通知的点击事件,如果使用户长按（3DTouch）、弹出Action页面等并不会触发。点击Action的时候会触发！
- (void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)())completionHandler {
    
    NSString *actionIdentify = response.actionIdentifier;
    //输入
    if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {
        
        NSString* userSayStr = [(UNTextInputNotificationResponse *)response userText];
        NSLog(@"actionid = %@\n  userSayStr = %@",actionIdentify, userSayStr);
    }
    
    //点击
    if ([actionIdentify isEqualToString:@"action.join"]) {
        
        NSLog(@"actionid = %@\n",actionIdentify);
        
    }else if ([actionIdentify isEqualToString:@"action.look"]){
        
        NSLog(@"actionid = %@\n",actionIdentify);
    }

    
    //收到推送的请求
    UNNotificationRequest *request = response.notification.request;
    
    //收到推送的内容
    UNNotificationContent *content = request.content;
    
    //收到用户的基本信息
    NSDictionary *userInfo = content.userInfo;
    
    //收到推送消息的角标
    NSNumber *badge = content.badge;
    
    //收到推送消息body
    NSString *body = content.body;
    
    //推送消息的声音
    UNNotificationSound *sound = content.sound;
    
    // 推送消息的副标题
    NSString *subtitle = content.subtitle;
    
    // 推送消息的标题
    NSString *title = content.title;
    
    if([response.notification.request.trigger isKindOfClass:[UNPushNotificationTrigger class]]) {
        NSLog(@"iOS10 收到远程通知:%@",userInfo);
        
    }else {
        // 判断为本地通知
        NSLog(@"iOS10 收到本地通知:{\\\\nbody:%@，\\\\ntitle:%@,\\\\nsubtitle:%@,\\\\nbadge：%@，\\\\nsound：%@，\\\\nuserInfo：%@\\\\n}",body,title,subtitle,badge,sound,userInfo);
    }
    
    // Warning: UNUserNotificationCenter delegate received call to -userNotificationCenter:didReceiveNotificationResponse:withCompletionHandler: but the completion handler was never called.
    completionHandler(); // 系统要求执行这个方法
}

@end
















