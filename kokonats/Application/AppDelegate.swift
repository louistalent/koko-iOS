//
//  AppDelegate.swift
//  kokonats
//
//  Created by sean on 2021/07/10.
//

import UIKit
import FirebaseAuth
import Firebase
import GoogleSignIn
import StoreKit
import FirebaseFirestore


@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        FirebaseApp.configure()

        let db = Firestore.firestore()

        //It is important to add the observer at launch, in application(_:didFinishLaunchingWithOptions:), to ensure that it persists during all launches of your app, receives all payment queue notifications, and continues transactions that may be processed outside the app, such as:
        //https://developer.apple.com/documentation/storekit/original_api_for_in-app_purchase/setting_up_the_transaction_observer_for_the_payment_queue
        SKPaymentQueue.default().add(PurchaseManager.shared)
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    @available(iOS 9.0, *)
    func application(_ application: UIApplication, open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }

    func applicationWillTerminate(_ application: UIApplication) {
        SKPaymentQueue.default().remove(PurchaseManager.shared)
    }
}

