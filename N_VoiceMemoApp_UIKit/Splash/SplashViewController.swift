//
//  LaunchViewController.swift
//  N_VoiceMemoApp_UIKit
//
//  Created by wodnd on 5/4/25.
//

import UIKit

class SplashViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5){
            let storyboard = UIStoryboard(name: "Onboarding", bundle: nil)
            let viewController = storyboard.instantiateViewController(identifier: "ViewController") as! ViewController
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first(where: {$0.isKeyWindow}) {
                window.rootViewController = viewController
            }
        }
    }

}
