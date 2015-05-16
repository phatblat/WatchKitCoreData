//
//  ViewController.swift
//  WatchKitCoreData
//
//  Created by Ben Chatelain on 5/14/15.
//  Copyright (c) 2015 Ben Chatelain. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var counterLabel: UILabel?

    override func viewDidLoad() {
        super.viewDidLoad()
        counterLabel?.text = "-1"
    }

}

