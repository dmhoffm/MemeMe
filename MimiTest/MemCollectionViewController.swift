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
    
    var refresh = false //to force table refresh from another controller
    
    // screen size parameters
    var screenSize: CGRect!
    var screenWidth: CGFloat!
    var screenHeight: CGFloat!
    
    // outlets
    
    @IBOutlet weak var memeCollection: UICollectionView!
        
    // button actions
    @IBAction func addMeme(sender: UIBarButtonItem) {
    
        // get the Meme Edit View Controller
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditViewController") as! MemeEditViewController
        
        // alert to meme editor
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // call backs
    
    // number of items in collection
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        println("collection count=\(self.memes.count)")
        return self.memes.count
    }
    
    // create cell for display
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = self.memes[indexPath.row]
        
        // Set the image
        cell.memedImage.image = meme.memedImage
        
        return cell
    }
    
    // select a cell the meme editing view
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
        
        // set up notifier to reload table
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMemes:",name:"refreshMemes", object: nil)
    }
    
    // when view is about to appear, obtain memes array from model
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // refresh collection if notified that it needs to be refreshed
        if self.refresh {
            println("refresh collection")
            self.refresh = false
            self.memeCollection.reloadData()
        }
    }
    
    // when view is about to dissappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // notifier function to cause Memes in table to be refreshed
    func refreshMemes(notification: NSNotification) {
        self.refresh = true
    }
    
    // remove notifications when this controller goes away
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // utilities
    
    
    
}
