//
//  ViewController.m
//  LocalNotification
//
//  Created by 祁子栋 on 2018/3/12.
//  Copyright © 2018年 祁子栋. All rights reserved.
//

#import "ViewController.h"
#import <UserNotifications/UserNotifications.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)sendNotification:(id)sender {
//    [self sendTimeLoaclWithImageiOS10];
    [self sendtimeLoaclWithGif];
}

-(void)sendiOS89LocalNotification {
    //发送一个本地通知：
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.alertBody = @"hello--alertBody"; //发送内容
    localNotification.fireDate = [NSDate dateWithTimeIntervalSinceNow:5];  //发送时间
    //    localNotification.timeZone = [NSTimeZone defaultTimeZone];
    //--------------------可选属性------------------------------
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.2) {
        localNotification.alertTitle = @"推送通知提示标题：alertTitle"; // iOS8.2之后
    }
    // 锁屏时在推送消息的最下方显示设置的提示字符串
    localNotification.alertAction = @"点击查看消息";
    
    // 当点击推送通知消息时，首先显示启动图片，然后再打开App, 默认是直接打开App的
    localNotification.alertLaunchImage = @"LaunchImage.png";
    
    // 默认是没有任何声音的 UILocalNotificationDefaultSoundName：声音类似于震动的声音
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    
    // 传递参数
    localNotification.userInfo = @{@"type": @"1"};
    
    //重复间隔：类似于定时器，每隔一段时间就发送通知,这里是每分钟，也可以每天，每周，每月。。。
    localNotification.repeatInterval = kCFCalendarUnitMinute;
    
    localNotification.category = @"choose--category"; // 附加操作的identifier
    
    // 定时发送
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    //    NSInteger applicationIconBadgeNumber =  [[UIApplication sharedApplication] applicationIconBadgeNumber] + 1;
    //    [[UIApplication sharedApplication] setApplicationIconBadgeNumber:applicationIconBadgeNumber];
    
    // 立即发送
    //    [[UIApplication sharedApplication] presentLocalNotificationNow:localNotification];
}

-(void)sendTimeLoaclWithImageiOS10 {//推送包含图片
    if (@available(iOS 10.0, *)) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = @"\"Fly to the moon\"";
        content.subtitle = @"by Neo";
        content.body = @"the wonderful song with you~🌑";
        content.badge = @0;
        content.categoryIdentifier = @"choseCategory";
        content.userInfo = @{@"ios10": @"iOS10推送"};
        //推送附件--图片
        NSString *path = [[NSBundle mainBundle] pathForResource:@"image1" ofType:@"png"];
        NSError *error = nil;
        UNNotificationAttachment *img_attachment = [UNNotificationAttachment attachmentWithIdentifier:@"att1" URL:[NSURL fileURLWithPath:path] options:nil error:&error];
        if (error) {
            NSLog(@"%@", error);
        }
        content.attachments = @[img_attachment];
        //设置为@""以后，进入app将没有启动页
        content.launchImageName = @"";
        UNNotificationSound *sound = [UNNotificationSound defaultSound];
        content.sound = sound;
        //设置一定时间之后开始通知，还有在某个时间通知UNCalendarNotificationTrigger，和在某个地点通知UNLocationNotificationTrigger
        //推送类型
        UNTimeIntervalNotificationTrigger *time_trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:5 repeats:NO];
        NSString *requestIdentifer = @"time interval request";
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:time_trigger];
        
        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            NSLog(@"%@",error);
        }];
    } else {
        // Fallback on earlier versions
    }
}

-(void)sendtimeLoaclWithGif{
    if (@available(iOS 10.0, *)) {
        NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSURLSession *session = [NSURLSession sessionWithConfiguration:config];
        NSURLSessionDataTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"http://ww3.sinaimg.cn/large/006y8lVagw1faknzht671g30b408c1l2.gif"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            if (!error) {
                NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"tmp/%@att.%@",@([NSDate date].timeIntervalSince1970),@"gif"]];
                NSError *err = nil;
                [data writeToFile:path atomically:YES];
                UNNotificationAttachment *gif_attachment = [UNNotificationAttachment attachmentWithIdentifier:@"attachment" URL:[NSURL fileURLWithPath:path] options:@{UNNotificationAttachmentOptionsThumbnailClippingRectKey:[NSValue valueWithCGRect:CGRectMake(0, 0, 1, 1)]} error:&err];
                UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
                content.title = @"\"Fly to the moon\"";
                content.subtitle = @"by Neo";
                content.body = @"the wonderful song with you~🌑";
                content.badge = @0;
                NSError *error = nil;
                if (gif_attachment) {
                    content.attachments = @[gif_attachment];
                }
                if (error) {
                    NSLog(@"%@", error);
                }
                //设置为@""以后，进入app将没有启动页
                content.launchImageName = @"";
                UNNotificationSound *sound = [UNNotificationSound defaultSound];
                content.sound = sound;
                
                UNTimeIntervalNotificationTrigger *time_trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:10 repeats:NO];
                NSString *requestIdentifer = @"time interval request";
                content.categoryIdentifier = @"seeCategory";
                UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:requestIdentifer content:content trigger:time_trigger];
                [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
                    NSLog(@"%@",error);
                }];
            }
        }];
        [task resume];
    }
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
