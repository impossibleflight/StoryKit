//
//  LoginViewController.swift
//  StoryKitDemo
//
//  Created by John Clayton on 11/6/18.
//  Copyright © 2018 Impossible Flight, LLC. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

	@IBAction func loginAction(_ sender: Any) {
		Container.instance.state.login()
//		stage.dismiss().perform()
	}
}
