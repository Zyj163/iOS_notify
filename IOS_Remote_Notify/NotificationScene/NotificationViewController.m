//
//  NotificationViewController.m
//  NotificationScene
//
//  Created by ddn on 16/11/4.
//  Copyright © 2016年 xitong. All rights reserved.
//

//在MainInterface.storyboard中自定你的UI页面，可以随意发挥，但是这个UI见面只能用于展示，并不能响应点击或者手势其他事件
//在Notifications Content 的info.plist中把NSExtensionMainStoryboard替换为NSExtensionPrincipalClass，并且value对应你的类名！可以不使用storyboard
//如果添加了category，需要在Notification content的info.plist添加一个键值对UNNotificationExtensionCategory的value值和category Action的category值保持一致就行
//如果想把default content 隐藏掉，只需要在Notification Content 的info.plist中添加一个键值UNNotificationExtensionDefaultContentHidden设置为YES就可以了:

#import "NotificationViewController.h"
#import <UserNotifications/UserNotifications.h>
#import <UserNotificationsUI/UserNotificationsUI.h>

@interface NotificationViewController () <UNNotificationContentExtension>

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property IBOutlet UILabel *label;

@end

@implementation NotificationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any required interface initialization here.
}

- (void)didReceiveNotification:(UNNotification *)notification {
    self.label.text = notification.request.content.body;
    
    UNNotificationContent *content = notification.request.content;
    UNNotificationAttachment *attachment = content.attachments.firstObject;
    if (attachment.URL.startAccessingSecurityScopedResource) {
        self.imageView.image = [UIImage imageWithContentsOfFile:attachment.URL.path];
    }
}

@end
