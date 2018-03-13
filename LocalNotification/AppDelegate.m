//
//  AppDelegate.m
//  LocalNotification
//
//  Created by 祁子栋 on 2018/3/12.
//  Copyright © 2018年 祁子栋. All rights reserved.
//

#import "AppDelegate.h"
#import <UserNotifications/UserNotifications.h>

@interface AppDelegate ()<UNUserNotificationCenterDelegate>

@end

@implementation AppDelegate

    //launchOptions ：启动选项参数：当程序是通过点击应用程序图标时该参数是nil，当应用程序完全退出时，点击推送通知时该参数不为空，key为UIApplicationLaunchOptionsLocalNotificationKey(本地)或者UIApplicationLaunchOptionsRemoteNotificationKey(远程)
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    if ([application respondsToSelector:@selector(registerUserNotificationSettings:)] && [[[UIDevice currentDevice] systemVersion] floatValue] < 10.0) {//iOS8以后
        //1.简单的注册一个通知，向用户请求可以给用户推送消息
        [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
        [self registeriOS89LocalNotification];//在iOS10之后可以发通知但没有操作按钮了
//        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
//        [application registerUserNotificationSettings:settings];
        // 2.注册远程通知(拿到用户的DeviceToken)
        [application registerForRemoteNotifications];
        
    }else if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 10.0) {
//        [self registeriOS89LocalNotification];
        [self registeriOS10LocalNotification];
    }
    else { // iOS 7 and earlier
        //
        [application registerForRemoteNotificationTypes:
         UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge |
         UIRemoteNotificationTypeSound];
    }
    
    return YES;
}
//远程通知注册成功回调这里，会有一个deviceToken
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken{
    NSLog(@"%@", deviceToken);
}
//远程通知注册失败回调这里
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error{
    NSLog(@"%@", error);
}

- (void)registeriOS89LocalNotification {
    //创建带动作的通知消息（iOS9才支持快捷回复）
    // categories: 推送消息的附加操作，可以为nil,此时值显示消息，如果不为空，可以在推送消息的后面增加几个按钮（如同意、不同意）
    UIMutableUserNotificationCategory *category = [[UIMutableUserNotificationCategory alloc] init];
    //这组动作的唯一标示,这里要注意与发送的通知的identifier一致，否则看不到相应的操作按钮的
    category.identifier = @"choose--category";
    //同意按钮
    UIMutableUserNotificationAction *agreeAction = [[UIMutableUserNotificationAction alloc] init];
    agreeAction.identifier = @"agree";
    agreeAction.title = @"同意";
    agreeAction.activationMode = UIUserNotificationActivationModeForeground;
    //需要解锁才能处理(意思就是如果在锁屏界面收到通知，并且iPhone设置了屏幕锁，点击了赞不会直接进入我们的回调进行处理，而是需要输入屏幕锁密码之后才进入我们的回调)，如果action.activationMode = UIUserNotificationActivationModeForeground;则这个属性被忽略；
    agreeAction.authenticationRequired = YES;
    /*
     destructive属性设置后，在通知栏或锁屏界面左划，按钮颜色会变为红色
     如果两个按钮均设置为YES，则均为红色（略难看）
     如果两个按钮均设置为NO，即默认值，则第一个为蓝色，第二个为浅灰色
     如果一个YES一个NO，则都显示对应的颜色，即红蓝双色 (CP色)。
     */
    agreeAction.destructive = NO;
    
    //不同意按钮加原因输入框
    UIMutableUserNotificationAction *disagreeAction = [[UIMutableUserNotificationAction alloc] init];
    disagreeAction.identifier = @"disagree";
    disagreeAction.title = @"不同意";
    disagreeAction.activationMode = UIUserNotificationActivationModeBackground;  // 后台模式，点击了按钮就完了
    disagreeAction.authenticationRequired = true;
    disagreeAction.destructive = true;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
        disagreeAction.behavior = UIUserNotificationActionBehaviorTextInput;
        disagreeAction.parameters = @{UIUserNotificationTextInputActionButtonTitleKey: @"拒绝原因"};
    }
    
    //将创建动作(按钮)加入附加操作category
    [category setActions:@[agreeAction, disagreeAction] forContext:UIUserNotificationActionContextMinimal];
    NSSet<UIUserNotificationCategory *> *categories = [NSSet setWithObjects:category, nil];//可以添加多组不同的动作
    [[UIApplication sharedApplication] registerUserNotificationSettings: [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:categories]];
}

// (iOS9及之前)本地通知回调函数，当应用程序在前台或者后台（未被杀死）点击通知进入APP时调用
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification{
    NSLog(@"%@------------%@", notification, notification.userInfo);
}
//在非本App界面时收到本地消息，下拉消息会有快捷回复的按钮，点击按钮后调用的方法，根据identifier来判断点击的哪个按钮，notification为消息内容()
// 监听附加操作按钮，iOS9.0之前调用这个方法
- (void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(nonnull UILocalNotification *)notification completionHandler:(nonnull void (^)())completionHandler {
    NSLog(@"identifier---%@/n notification---%@/n", identifier, notification);
    completionHandler();
}
// 该方法在iOS9.0后调用   监听附加操作按钮
-(void)application:(UIApplication *)application handleActionWithIdentifier:(nullable NSString *)identifier forLocalNotification:(nonnull UILocalNotification *)notification withResponseInfo:(nonnull NSDictionary *)responseInfo completionHandler:(nonnull void (^)())completionHandler {
    NSLog(@"identifier---%@/n notification---%@/n responseInfo---%@", identifier, notification, responseInfo);//
    if ([identifier isEqualToString:@"agree"]) {
        [self showAlertView:@"点了赞"];
    } else if ([identifier isEqualToString:@"disagree"]) {
        if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 9.0) {
            [self showAlertView:[NSString stringWithFormat:@"用户评论为:%@", responseInfo[UIUserNotificationActionResponseTypedTextKey]]];
        }else {
            [self showAlertView:[NSString stringWithFormat:@"用户不同意"]];
        }
    }
    
    completionHandler();
}
//已经收到远程推送回调。点进去看注释就可以进行适配了，下面也有代码
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo{
    
}
//已经收到远程推送回调。点进去看注释就可以进行适配iOS 10了，下面也有代码
-(void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler{
    
}
//远程推送的按钮事件响应回调。点进去看注释就可以进行适配iOS 10了，下面也有代码
- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo completionHandler:(void (^)())completionHandler {
    
}
//远程推送的按钮事件响应回调。点进去看注释就可以进行适配iOS 10了，下面也有代码
-(void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)userInfo withResponseInfo:(NSDictionary *)responseInfo completionHandler:(void (^)())completionHandler {
    
}

- (void)showAlertView:(NSString *)message
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    [self.window.rootViewController showDetailViewController:alert sender:nil];
}


- (void) registeriOS10LocalNotification {
    if (@available(iOS 10.0, *)) {
        UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
        // 必须写代理，不然无法监听通知的接收与点击
        center.delegate = self;
        //添加按钮交互
        [center setNotificationCategories:[self createNotificationCategoryActions]];
        [center getNotificationSettingsWithCompletionHandler:^(UNNotificationSettings * _Nonnull settings) {
            if (settings.authorizationStatus == UNAuthorizationStatusNotDetermined) {
                [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionBadge | UNAuthorizationOptionSound) completionHandler:^(BOOL granted, NSError * _Nullable error) {
                    if (granted) {//用户点击允许通知，本地通知注册好了
                        //同时注册远程通知
                        [[UIApplication sharedApplication] registerForRemoteNotifications];
                    }else {
                        //用户点击不允许
                        NSLog(@"注册失败");
                    }
                }];
            }
        }];
        
    }
}
-(NSSet *)createNotificationCategoryActions{
    //定义按钮的交互button action
    if (@available(iOS 10.0, *)) {
        /**
         UNNotificationActionOptionAuthenticationRequired: 锁屏时需要解锁才能触发事件，触发后不会直接进入应用，不常用
         UNNotificationActionOptionDestructive：字体会显示为红色，且锁屏时触发该事件不需要解锁，触发后不会直接进入应用
         UNNotificationActionOptionForeground：锁屏时需要解锁才能触发事件，触发后会直接进入应用界面
         */
        UNNotificationAction * likeButton = [UNNotificationAction actionWithIdentifier:@"see1" title:@"I love it~😘" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];//这里的identifier主要用于下方的业务判断
        UNNotificationAction * dislikeButton = [UNNotificationAction actionWithIdentifier:@"see2" title:@"I don't care~😳" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
        //定义文本框的action
        UNTextInputNotificationAction * text = [UNTextInputNotificationAction actionWithIdentifier:@"text" title:@"How about it~?" options:UNNotificationActionOptionAuthenticationRequired|UNNotificationActionOptionDestructive|UNNotificationActionOptionForeground];
        //将这些action带入category，注意category的identifier要与发送时本地通知的content的identifier一致
        UNNotificationCategory * choseCategory = [UNNotificationCategory categoryWithIdentifier:@"choseCategory" actions:@[likeButton,dislikeButton] intentIdentifiers:@[@"see1",@"see2"] options:UNNotificationCategoryOptionNone];
        UNNotificationCategory * comment = [UNNotificationCategory categoryWithIdentifier:@"seeCategory" actions:@[text] intentIdentifiers:@[@"text"] options:UNNotificationCategoryOptionNone];
        return [NSSet setWithObjects:choseCategory,comment,nil];
    } else {
        // Fallback on earlier versions
        return nil;
    }
}

//iOS10之后通知代理回调方法，APP在前台时触发，通知即将展示的时候
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    
    if (@available(iOS 10.0, *)) {
        UNNotificationRequest *request = notification.request;// 原始请求
        NSDictionary * userInfo = notification.request.content.userInfo;//userInfo数据
        UNNotificationContent *content = request.content; // 原始内容
        NSString *title = content.title;  // 标题
        NSString *subtitle = content.subtitle;  // 副标题
        NSNumber *badge = content.badge;  // 角标
        NSString *body = content.body;    // 推送消息体
        UNNotificationSound *sound = content.sound;  // 指定的声音
        //建议将根据Notification进行处理的逻辑统一封装，后期可在Extension中复用~
        if ([notification isKindOfClass:[UNPushNotificationTrigger class]]) {
            NSLog(@"iOS10 收到远程通知:%@",userInfo);
        }else{
            NSLog(@"iOS10 收到本地通知:%@",[notification description]);
        }
        completionHandler(UNAuthorizationOptionBadge|UNAuthorizationOptionSound|UNAuthorizationOptionAlert);
    } else {
        // Fallback on earlier versions
    }
    
}
//iOS10之后用户与通知进行交互后的response，比如说用户直接点开通知打开App、用户点击通知的按钮或者进行输入文本框的文本
-(void)userNotificationCenter:(UNUserNotificationCenter *)center didReceiveNotificationResponse:(UNNotificationResponse *)response withCompletionHandler:(void (^)(void))completionHandler {
    if (@available(iOS 10.0, *)) {
        UNNotificationRequest *request = response.notification.request; // 原始请求
        NSDictionary * userInfo = request.content.userInfo;//userInfo数据
        UNNotificationContent *content = request.content; // 原始内容
        NSString *title = content.title;  // 标题
        NSString *subtitle = content.subtitle;  // 副标题
        NSNumber *badge = content.badge;  // 角标
        NSString *body = content.body;    // 推送消息体
        UNNotificationSound *sound = content.sound;
        //在此，可判断response的种类和request的触发器是什么，可根据远程通知和本地通知分别处理，再根据action进行后续回调
        //可根据actionIdentifier来做业务逻辑
        if ([response isKindOfClass:[UNTextInputNotificationResponse class]]) {//判断response类型
            UNTextInputNotificationResponse * textResponse = (UNTextInputNotificationResponse*)response;
            NSString * text = textResponse.userText;
            //do something
            UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"文本框输入" message:text preferredStyle:UIAlertControllerStyleAlert];
            [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:nil]];
            [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
        }
        else{
            if ([response.actionIdentifier isEqualToString:@"see1"]) {
                //I love it~😘的处理
            }
            if ([response.actionIdentifier isEqualToString:@"see2"]) {
                //I don't care~😳
                [[UNUserNotificationCenter currentNotificationCenter] removeDeliveredNotificationsWithIdentifiers:@[response.notification.request.identifier]];
                UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"点了按钮" message:response.notification.request.content.body preferredStyle:UIAlertControllerStyleAlert];
                [alert addAction:[UIAlertAction actionWithTitle:@"I don't care~😳" style:UIAlertActionStyleDefault handler:nil]];
                [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
            }
        }
    }
    completionHandler();
}




- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
