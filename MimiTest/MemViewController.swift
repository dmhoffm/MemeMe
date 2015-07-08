//
//  MemViewController.swift
//  MimiTest
//
//  Created by David Hoffman on 6/29/15.
//  Copyright (c) 2015 dmhoffm. All rights reserved.
//

import Foundation
import UIKit

class MemeViewController: UIViewController, UINavigationControllerDelegate, UITableViewDataSource, UITableViewDelegate {
    
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
    
    // meme table view

    @IBOutlet weak var memeTable: UITableView!
    
    //
    // button actions
    
    // create (+) new meme
    @IBAction func addMeme(sender: UIBarButtonItem) {
        // get the Meme Edit View Controller
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditViewController")   as! UIViewController
        // alert to meme editor
        self.presentViewController(controller, animated: true,  completion: nil)
    }
    
    //
    // table call backs
    
    // number of saved memes
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        println("count=\(self.memes.count)")
        return self.memes.count
    }
    
    // create meme table cell for display
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCellWithIdentifier("MemeCell") as! MemeTableViewCell
        let meme = self.memes[indexPath.row]
        
        // Set the image
        cell.memeImage.image = meme.memedImage
        
        // Set the label
        cell.memeLabel.text = "\(meme.upperText!)...\(meme.lowerText!)"
        
        return cell
    }
    
    // select table cell and goto back to editor
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        // get the Meme Detail View Controller
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeDetailViewController") as! MemeDetailViewController
        
        // seed with index of selected Meme
        controller.indexPath = indexPath
        
        // push to meme editor
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    // when view is loaded set up components
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // set up tableView data source and delegate
        self.memeTable.dataSource = self
        self.memeTable.delegate = self
        
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
        if self.refresh {
            println("refresh table")
            self.refresh = false
            self.memeTable.reloadData()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    // when view is about to dissappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }

    
    // notifier function to cause Memes in table to be refreshed
    func refreshMemes(notification: NSNotification) {
        self.refresh = true
    }
    
    // utilities
    
    
    
}
