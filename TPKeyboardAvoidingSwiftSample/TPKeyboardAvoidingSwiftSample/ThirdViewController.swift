//
//  ThirdViewController.swift
//  TPKeyboardAvoidingSwiftSample
//
//  Created by Manuele Mion on 25/02/15.
//  Copyright (c) 2015 TPKeyboardAvoiding. All rights reserved.
//

import UIKit
import Foundation

class ThirdViewController: UICollectionViewController {
    
    override func viewDidLoad() {
        let nib = UINib(nibName: "ThirdCollectionViewCell", bundle: nil)
        self.collectionView?.registerNib(nib, forCellWithReuseIdentifier: "cell")
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 30
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as UICollectionViewCell
        return cell
    }
        
}