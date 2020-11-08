//
//  FirstViewController.swift
//  TPKeyboardAvoidingSwiftSample
//
//  Created by Manuele Mion on 25/02/15.
//  Copyright (c) 2015 TPKeyboardAvoiding. All rights reserved.
//

import UIKit
import Foundation

class FirstViewController: UIViewController {

    @IBOutlet weak var scrollView: TPKeyboardAvoidingScrollView!
    
    override func viewDidLoad() {
        self.scrollView.contentSizeToFit()
        super.viewDidLoad()
    }
    
}
