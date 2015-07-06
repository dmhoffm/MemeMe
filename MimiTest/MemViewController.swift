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
    
    //
    // outlets
    
    // meme table view
    @IBOutlet weak var memeTable: UITableView!
    
    //
    // button actions
    
    // create (+) new meme
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
    
    //
    // table call backs
    
    // number of saved memes
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        
        // set up tableView data source and delegate
        self.memeTable.dataSource = self
        self.memeTable.delegate = self
    }
    
    // when view is about to appear, obtain memes array from model
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // when view is about to dissappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // utilities
    
    
    
}
