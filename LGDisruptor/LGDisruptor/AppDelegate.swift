//
//  AppDelegate.swift
//  LGDisruptor
//
//  Created by Luka Gabrić on 10/11/2019.
//  Copyright © 2019 LG. All rights reserved.
//

import UIKit

let MessageOptionKey = "MessageOption"
let ReceivedMessageOptionKey = "ReceivedMessageOption"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate
{
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool
    {
        UserDefaults.standard.register(defaults: [MessageOptionKey: MessageOption.noLineEnding.rawValue,
                                                  ReceivedMessageOptionKey: ReceivedMessageOption.none.rawValue])
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        window?.rootViewController = UINavigationController(rootViewController: SerialViewController())
        window?.makeKeyAndVisible()
        
        return true
    }

}

