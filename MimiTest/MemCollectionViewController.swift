//
//  MemCollectionViewController.swift
//  MimiTest
//
//  Created by David Hoffman on 7/4/15.
//  Copyright (c) 2015 dmhoffm. All rights reserved.
//

import Foundation

import UIKit

class MemeCollectionViewController: UIViewController, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
    
    // current saved meme array
    var memes: [Meme]! {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.memes
        }
    }
    
    // screen size parameters
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    // outlets
    
    @IBOutlet weak var memeCollection: UICollectionView!
        
    // button actions
    @IBAction func addMeme(sender: UIBarButtonItem) {
        // get the Meme Edit View Controller
        let controller = self.presentingViewController as! MemeEditViewController
        
        // set selected Meme to blank Meme Editor controller
        controller.image.image = nil
        controller.bottomText.text = nil
        controller.topText.text = nil
        
        // return to meme editor
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // collection call backs
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("collection count = \(self.memes.count)");
        return self.memes.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = self.memes[indexPath.row]
        
        // Set the image
        cell.memedImage.image = meme.memedImage
        
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectCellAtIndexPath indexPath: NSIndexPath) {
        
        // get the Meme Edit View Controller
        let controller = self.presentingViewController as! MemeEditViewController
        controller.selectedMeme = self.memes[indexPath.row]
        // return to meme editor with selected meme to re-edit the meme
        self.dismissViewControllerAnimated(true, completion: nil)
        
    }
    
    // when view is loaded set up components
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set up collectionView data source and delegate
        self.memeCollection.dataSource = self
        self.memeCollection.delegate = self
        // set up screen size parameters
        screenSize = UIScreen.mainScreen().bounds
        screenWidth = screenSize.width
        screenHeight = screenSize.height
        // set layout parameters
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: screenWidth / 3, height: screenWidth / 3)
        // self.memeCollection.setCollectionViewLayout(layout, animated: true)
    }
    
    // when view is about to appear, obtain memes array from model
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        
        println("viewWillAppear")
    }
    
    // when view is about to dissappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // utilities
    
    
    
}
