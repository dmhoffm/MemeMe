//
//  MemViewController.swift
//  MimiTest
//
//  Created by David Hoffman on 6/29/15.
//  Copyright (c) 2015 dmhoffm. All rights reserved.
//

import Foundation
import UIKit

class MemeViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate,UICollectionViewDataSource, UICollectionViewDelegate {
    
    // current saved meme array
    var memes: [Meme]! {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.memes
        }
    }
    
    var refresh = false //to force table refresh from another controller
    
    //
    // outlets
    
    // meme collection view
    @IBOutlet weak var memeCollection: UICollectionView!

    // meme table view
    @IBOutlet weak var memeTable: UITableView!
    
    //
    // button actions
    
    // create (+) new meme
    @IBAction func addMeme(sender: UIBarButtonItem) {
        // get the Meme Edit View Controller
        let controller = storyboard?.instantiateViewControllerWithIdentifier("MemeEditViewController")   as! MemeEditViewController
        
        // indicated need to create meme
        controller.indexPath = nil
        
        // push to meme editor
        presentViewController(controller, animated: true,  completion: nil)
    }
    
    //
    // table call backs
    
    // number of saved memes
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfMemes()
    }
    
    // create meme table cell for display
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell") as! MemeTableViewCell
        let meme = memes[indexPath.row]
        
        // Set the image
        cell.memeImage.image = meme.memedImage
        
        // Set the label
        cell.memeLabel.text = "\(meme.upperText!)...\(meme.lowerText!)"
        
        return cell
    }
    
    // select table cell and goto back to detail view
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {

        pushToMemeDetailFor(indexPath)
    }
    
    //
    // collection view callbacks
    // number of items in collection
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfMemes()
    }
    
    // create cell for display
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MemeCollectionCell", forIndexPath: indexPath) as! MemeCollectionViewCell
        let meme = memes[indexPath.row]
        
        // Set the image
        cell.memedImage.image = meme.memedImage
        
        return cell
    }
    
    // select collection item and push to the meme detail view
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        pushToMemeDetailFor(indexPath)
    }
    
    // when view is loaded set up components
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up tableView data source and delegate
        if let tableView = memeTable {
            tableView.dataSource = self
            tableView.delegate = self
        }
        
        // set up collectionView data source and delegate
        if let collectionView = memeCollection {
            collectionView.dataSource = self
            collectionView.delegate = self
        }
        
        // set up notifier to reload table
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMemes:",name:"refreshMemes", object: nil)
    }
    
    // remove notifications when this controller goes away
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // when view is about to appear, obtain memes array from model
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        // refresh table if notified that it needs to be refreshed
        if refresh {
            refresh = false
            if let tableView = memeTable {
                tableView.reloadData()
            }
            if let collectionView = memeCollection {
                collectionView.reloadData()
            }
        }
    }
    
    // when view is about to appear
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // when view is about to dissappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    
    // notifier function to cause Memes in table to be refreshed
    func refreshMemes(notification: NSNotification) {
        refresh = true
    }
    
    // utilities
    
    //
    // Memes database related
    
    // current numebr of memes
    func numberOfMemes() -> Int {
        return memes.count
    }
    
    // push to Meme detail view for index in Memes
    func pushToMemeDetailFor(indexPath: NSIndexPath) {
        
        // get the Meme Detail View Controller
        let controller = storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        
        // seed with index of selected Meme
        controller.indexPath = indexPath
        
        // push to meme editor
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
