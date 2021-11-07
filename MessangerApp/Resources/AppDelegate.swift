//
//  AppDelegate.swift
//  MessangerApp
//
//  Created by administrator on 27/10/2021.
//

import UIKit
import IQKeyboardManagerSwift
import PasswordTextField
import Firebase
import GoogleSignIn
import FBSDKCoreKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate , GIDSignInDelegate  {
   

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        IQKeyboardManager.shared.enable = true
        FirebaseApp.configure()
        
        //google signin
        GIDSignIn.sharedInstance()?.clientID = FirebaseApp.app()?.options.clientID
        GIDSignIn.sharedInstance()?.delegate = self
        
        ApplicationDelegate.shared.application(
                    application,
                    didFinishLaunchingWithOptions: launchOptions
                )
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
    func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]
        ) -> Bool {

            ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
        return GIDSignIn.sharedInstance().handle(url, sourceApplication:options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String, annotation: [:])
        
    }
    

    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            if let error = error {print("failed to sign in with google \(error)")}
            return
        }
        guard
            let authentication = user?.authentication,
            let idToken = authentication.idToken
        else {
            return
        }
        guard let email = user.profile?.email,
              let firstName = user.profile?.name,
              let lastName = user.profile?.familyName else {return}
        DatabaseManger.shared.userExists(with: email, completion: {isexist in
            //the email is uniqe
            if isexist {
                DatabaseManger.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email, imageProfile: ""), completion: { _ in})
                let defaults = UserDefaults.standard
                defaults.set(email, forKey: "Email")
               
            }
        })
        guard let authentication = user.authentication else {return}
        let credentialGoogle = GoogleAuthProvider.credential(withIDToken: idToken,
                                                       accessToken: authentication.accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credentialGoogle, completion: {result , error in
            guard result != nil , error == nil else {return}
            print("auth")
            let defaults = UserDefaults.standard
            defaults.set(email, forKey: "Email")
            NotificationCenter.default.post(name: Notification.Name("LogInNotification"), object: nil)
        })

    }
    func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
        print("google account disconnected")
    }
}

