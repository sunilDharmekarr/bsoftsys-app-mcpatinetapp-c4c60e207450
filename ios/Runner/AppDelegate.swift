import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    
    private let APP_VERSION_CHANNEL = "patient.mumbaiclinic/appVersion"
    private let FCM_VERSION_CHANNEL = "patient.mumbaiclinic/fcm"
    private var fcmChannel: FlutterMethodChannel!
    var token: String!
    var notificationData: [AnyHashable : Any]!
    
    ///To get location notification object
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        
        ///----init local
        notificationCenter.delegate = self
        
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        notificationCenter.requestAuthorization(options: options) {
            (didAllow, error) in
            if !didAllow {
                print("User has declined notifications")
            }
        }
        ///----init local
        
        GeneratedPluginRegistrant.register(with: self)
        //FirebaseApp.configure()
        self.registerForPushNotification()
        Messaging.messaging().token { token, error in
            if let error = error {
                print("Error fetching FCM registration token: \(error)")
            } else if let token = token {
                print("FCM registration token: \(token)")
                self.token = token
            }
        }
        
        let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
        registerAppVersionChannel(controller: controller, channelName: APP_VERSION_CHANNEL)
        fcmChannel = registerFCMChannel(delegate: self, controller: controller, channelName: FCM_VERSION_CHANNEL)
        
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func userNotificationCenter( _ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
//        completionHandler([.alert, .sound])
        
        print("willPresent:")
        print(notification.request.content)
        print(notification.request.content.userInfo)
//        let state = UIApplication.shared.applicationState
//        if state == .active {
//            print("I'm active")
//        }
//        else if state == .inactive {
//            print("I'm inactive")
//        }
//        else if state == .background {
//            print("I'm in background")
//        }
        
        //self.sendData(notificationData: notification.request.content.userInfo)
        completionHandler([[.alert,.sound]])
    }
    
    override func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("click: -- didReceive")
        print(response.notification.request.content)
        print(response.notification.request.content.userInfo)
        
        //let userInfo = response.notification.request.content.userInfo
        self.sendData(notificationData: response.notification.request.content.userInfo)

//        <UNNotificationContent: 0x28287c750; title: <redacted>, subtitle: (null), body: <redacted>, summaryArgument: , summaryArgumentCount: 0, categoryIdentifier: Delete Notification Type, launchImageName: , threadIdentifier: , attachments: (
//        ), badge: 1, sound: <UNNotificationSound: 0x283866d80>, realert: 0
//        [:]
//
//        [AnyHashable("image"): https://picsum.photos/200, AnyHashable("title"): test title, AnyHashable("google.c.fid"): eCAcsCybgE6DmXZLYrKhJV, AnyHashable("android_channel_id"): video_call, AnyHashable("google.c.sender.id"): 74734635359, AnyHashable("aps"): {
//            "content-available" = 1;
//        }, AnyHashable("cdata"): 123|Dr. Test, AnyHashable("body"): Test body, AnyHashable("gcm.message_id"): 1635227065788317]
//
        
//        let notification_aps = userInfo["aps"]
////        let fcm_options = userInfo["fcm_options"] as? Dictionary<String, Any>
////        let imageURL = fcm_options!["image"] as? String
//
//        print("notificationType -- \(notificationType)")
//        print("message_id -- \(message_id!)")
//        print("notificationText -- \(notificationText!)")
//        //print("redirect_id -- \(notification_redirect_id)")
//        print("notification_aps -- \(notification_aps!)")
//
//        // Change this to your preferred presentation option
//        completionHandler([[.alert, .sound]])
//
//        //Redirect to news page
//        if notificationType == "news_publish"{
//            let notification_redirect_id = userInfo["gcm.notification.redirect_id"] as! String
//            NotificationCenter.default.post(name: .respondToNotification, object: notification_redirect_id)
//        }else if notificationType == "custom_notification"{
//            //NotificationCenter.default.post(name: .respondToNotification, object: nil)
//        }

        
        if response.notification.request.identifier == "Local Notification" {
            print("Handling notifications with the Local Notification Identifier")
        }

        completionHandler()
    }
    
    
    override func application(_ application: UIApplication,
                              didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                              fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult)
                                -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        
        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        
        // Print message ID.
        
        
        // Print full message.
        print(userInfo)
        
        
//        [AnyHashable("image"): https://picsum.photos/200, AnyHashable("title"): test title, AnyHashable("google.c.fid"): eCAcsCybgE6DmXZLYrKhJV, AnyHashable("android_channel_id"): video_call, AnyHashable("google.c.sender.id"): 74734635359, AnyHashable("aps"): {
//            "content-available" = 1;
//        }, AnyHashable("cdata"): 123|Dr. Test, AnyHashable("body"): Test body, AnyHashable("gcm.message_id"): 1635227065788317]
        
        let notificationTitle = userInfo["title"] as! String
        let notificationType = userInfo["android_channel_id"] as! String
        let notificationBody = userInfo["body"] as! String
        
        let is_video_call = (notificationType == "video_call")
        
        self.notificationData = userInfo
        
        let state = UIApplication.shared.applicationState
        if state == .active {
            print("I'm active")
            if is_video_call{
                self.sendData(notificationData: userInfo)
            }else{
                self.scheduleNotification(title: notificationTitle, body: notificationBody, notificationType: notificationType, userInfo:userInfo )
            }
        }
        else if state == .inactive {
            print("I'm inactive")
            if is_video_call{
                self.sendData(notificationData: userInfo)
            }else{
                self.scheduleNotification(title: notificationTitle, body: notificationBody, notificationType: notificationType, userInfo:userInfo )
            }
            
        }
        else if state == .background {
            print("I'm in background")
            self.scheduleNotification(title: notificationTitle, body: notificationBody, notificationType: notificationType, userInfo:userInfo )
        }
        
        completionHandler(UIBackgroundFetchResult.newData)
    }
    
    
    func sendData(notificationData: [AnyHashable : Any]) {
//
//        let ch_id = notificationData["android_channel_id"] as! Int
//        let type = notificationData["notificationType"] as! String
//
//        let data: [String: Any] = ["android_channel_id":ch_id,
//                                   "notificationType":type]
////        result(data)
//        print(" ------> \(notificationData["android_channel_id"] ?? "--")")
//
//        if (notificationData["android_channel_id"] != nil) {
//            self.notificationData["notificationType"] = notificationData["android_channel_id"]
//
//        } else {
//            self.notificationData["notificationType"] = "generic"
//        }
//
//        print(" ------> \(self.notificationData["notificationType"] ?? "--")")
//
//        fcmChannel.invokeMethod("onMessageReceived", arguments: data)
        
        var data: [String :  Any] = [:]
                if (notificationData["android_channel_id"] != nil) {
                    data["notificationType"] = notificationData["android_channel_id"] as! String
                } else {
                    data["notificationType"] = "generic"
                }
                data["cdata"] = notificationData["cdata"] as! String
                data["image"] = notificationData["image"] as? String ?? ""
        
                fcmChannel.invokeMethod("onMessageReceived", arguments: data)
    }
    
    /// Register for push notifications
    func registerForPushNotification(){
        
        if #available(iOS 10.0, *) {
            let center  = UNUserNotificationCenter.current()
            center.delegate = self
            center.requestAuthorization(options: [.sound, .alert, .badge]) { (granted, error) in
                if error == nil{
                    DispatchQueue.main.async {
                        UIApplication.shared.registerForRemoteNotifications()
                    }
                }
            }
        } else {
            
            let settings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
    }
    
    
    //-----Added methods ----
    override func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    override func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    override func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }
    
    override func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    //-----Added methods ----
    
    func scheduleNotification(title: String, body: String, notificationType: String, userInfo: [AnyHashable : Any]) {
        
        let content = UNMutableNotificationContent() // Содержимое уведомления
        let categoryIdentifire = "Delete Notification Type"
        
        content.title = title
        content.body = body
        content.sound =  (notificationType == "video_call") ? UNNotificationSound.default : UNNotificationSound.default
        content.badge = 1
        content.categoryIdentifier = categoryIdentifire
        content.userInfo = userInfo
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let identifier = "Local Notification"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        notificationCenter.add(request) { (error) in
            if let error = error {
                print("Error \(error.localizedDescription)")
            }
        }
        
        let snoozeAction = UNNotificationAction(identifier: "Snooze", title: "Snooze", options: [])
        let deleteAction = UNNotificationAction(identifier: "DeleteAction", title: "Delete", options: [.destructive])
        let category = UNNotificationCategory(identifier: categoryIdentifire,
                                              actions: [snoozeAction, deleteAction],
                                              intentIdentifiers: [],
                                              options: [])
        
        notificationCenter.setNotificationCategories([category])
    }
    
}

private func registerFCMChannel(delegate: AppDelegate, controller: FlutterViewController, channelName: String) -> FlutterMethodChannel {
    let fcmChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    fcmChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "getMessageData" {
            result(delegate.notificationData)
        } else if call.method == "getToken" {
            result(delegate.token)
        }  else if call.method == "removeMessageData" {
            delegate.notificationData = nil
            result(true)
        } else {
            result(FlutterMethodNotImplemented)
            return
        }
    })
    return fcmChannel
}

private func registerAppVersionChannel(controller: FlutterViewController, channelName: String) {
    let appVersionChannel = FlutterMethodChannel(name: channelName, binaryMessenger: controller.binaryMessenger)
    appVersionChannel.setMethodCallHandler({
        (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
        if call.method == "getAppVersionName" {
            result(Bundle.main.buildVersionName)
        } else if call.method == "getAppVersionCode" {
            result(Int(Bundle.main.buildVersionNumber ?? "1"))
        } else {
            result(FlutterMethodNotImplemented)
            return
        }
    })
}

extension Bundle {
    var buildVersionName: String? {
        return infoDictionary?["CFBundleShortVersionString"] as? String
    }
    var buildVersionNumber: String? {
        return infoDictionary?["CFBundleVersion"] as? String
    }
}



//extension AppDelegate: UNUserNotificationCenterDelegate {
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                willPresent notification: UNNotification,
//                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
//
//        completionHandler([.alert, .sound])
//    }
//
//    func userNotificationCenter(_ center: UNUserNotificationCenter,
//                                didReceive response: UNNotificationResponse,
//                                withCompletionHandler completionHandler: @escaping () -> Void) {
//
//        if response.notification.request.identifier == "Local Notification" {
//            print("Handling notifications with the Local Notification Identifier")
//        }
//
//        completionHandler()
//    }
//
//
//}
