//
//  ViewController.swift
//  ClickSign-iOS
//
//  Created by Ezequiel França on 30/05/17.
//  Copyright © 2017 Ezequiel França. All rights reserved.
//

import UIKit

class ViewController: UIViewController, ClickSignDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        let clickSignView = ClickSign(frame: view.frame, controller: self)
        self.view.addSubview(clickSignView)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

