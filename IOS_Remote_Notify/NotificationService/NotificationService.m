//
//  NotificationService.m
//  NotificationService
//
//  Created by ddn on 16/11/4.
//  Copyright © 2016年 xitong. All rights reserved.
//

#import "NotificationService.h"
#import <UIKit/UIKit.h>

@interface NotificationService ()

@property (nonatomic, strong) void (^contentHandler)(UNNotificationContent *contentToDeliver);
@property (nonatomic, strong) UNMutableNotificationContent *bestAttemptContent;

@end

@implementation NotificationService

#pragma mark: 可以在后台处理接收到的推送，传递最终的内容给 contentHandler
- (void)didReceiveNotificationRequest:(UNNotificationRequest *)request withContentHandler:(void (^)(UNNotificationContent * _Nonnull))contentHandler {
    self.contentHandler = contentHandler;
    self.bestAttemptContent = [request.content mutableCopy];
    
    // Modify the notification content here...
    //以图片为例
    NSString * attchUrl = [request.content.userInfo objectForKey:@"image"];
    //下载,放到本地，如果本地没有
    UIImage * imageFromUrl = [self getImageFromURL:attchUrl];
    
    //获取documents目录
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectoryPath = [paths firstObject];
    
    NSString * localPath = [self saveImage:imageFromUrl withFileName:@"MyImage" ofType:@"png" inDirectory:documentsDirectoryPath];
    if (localPath && ![localPath isEqualToString:@""]) {
        UNNotificationAttachment * attachment = [UNNotificationAttachment attachmentWithIdentifier:@"photo" URL:[NSURL URLWithString:[@"file://" stringByAppendingString:localPath]] options:nil error:nil];
        if (attachment) {
            self.bestAttemptContent.attachments = @[attachment];
        }
    }
    
    self.contentHandler(self.bestAttemptContent);
}

#pragma mark: 在你获得的一小段运行代码的时间即将结束的时候，如果仍然没有成功的传入内容，会走到这个方法，可以在这里传肯定不会出错的内容，或者他会默认传递原始的推送内容
- (void)serviceExtensionTimeWillExpire {
    // Called just before the extension will be terminated by the system.
    // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
    self.contentHandler(self.bestAttemptContent);
}

- (UIImage *) getImageFromURL:(NSString *)fileURL {
    NSLog(@"执行图片下载函数");
    UIImage * result;
    //dataWithContentsOfURL方法需要https连接
    NSData * data = [NSData dataWithContentsOfURL:[NSURL URLWithString:fileURL]];
    result = [UIImage imageWithData:data];
    
    return result;
}

//将所下载的图片保存到本地
- (NSString *) saveImage:(UIImage *)image withFileName:(NSString *)imageName ofType:(NSString *)extension inDirectory:(NSString *)directoryPath {
    NSString *urlStr = @"";
    if ([[extension lowercaseString] isEqualToString:@"png"]){
        urlStr = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]];
        [UIImagePNGRepresentation(image) writeToFile:urlStr options:NSAtomicWrite error:nil];
        
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] ||
               [[extension lowercaseString] isEqualToString:@"jpeg"]){
        urlStr = [directoryPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]];
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:urlStr options:NSAtomicWrite error:nil];
        
    } else{
        NSLog(@"extension error");
    }
    return urlStr;
}

@end
