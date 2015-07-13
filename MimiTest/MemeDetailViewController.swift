//
//  MemeDetailViewController.swift
//  MimiTest
//
//  Created by David Hoffman on 7/6/15.
//  Copyright (c) 2015 dmhoffm. All rights reserved.
//

import Foundation

import UIKit

class MemeDetailViewController: UIViewController,    UINavigationControllerDelegate {
    
    
    // current saved meme array
    var memes: [Meme]! {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.memes
        }
        
    }
    
    var indexPath: NSIndexPath? //selected Meme index from table/collection
 
    var refresh = false //to force image refresh from another controller
    
    //
    // outlets
    
    //main image on page
    @IBOutlet weak var image: UIImageView!
    
    //
    // button actions
    
    // "Trash" button
    // Delete Meme
    @IBAction func deleteMeme(sender: UIBarButtonItem) {
        //
        // seed with memed image of selected meme
        if let row = indexPath?.row {
            if row < memes.count {
                // remove element from saved memes
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.memes.removeAtIndex(row)
                // let the parent controllers know of the change
                NSNotificationCenter.defaultCenter().postNotificationName("refreshMemes", object: nil)
                // return to previous view
                navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    // Edit button
    @IBAction func editMeme(sender: UIBarButtonItem) {
        // get the Meme Edit View Controller
        let controller = storyboard?.instantiateViewControllerWithIdentifier("MemeEditViewController") as! MemeEditViewController
        
        // seed with memed image of selected meme 
        if let row = indexPath?.row {
            controller.indexPath = indexPath
        }
        
        // present meme editor
        presentViewController(controller, animated: true, completion: nil)
    }

    
    //
    // call backs
    
    // when view is loaded, set up components
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // set up notifier to reload table
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "refreshMemes:",name:"refreshMemes", object: nil)
    }
    
    // remove notifications when this controller goes away
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    
    // when view is about to appear,  set up picture
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // set to fill screen
        image.contentMode = UIViewContentMode.ScaleAspectFill
        
        // seed with memed image of selected meme if it's set
        if let row = indexPath?.row {
            image.image = memes[row].memedImage
        }
        
        // refresh image if notified that it needs to be refreshed
        if refresh {
            refresh = false
            view.setNeedsDisplay()
        }
    }
    
    // when view is about to dissappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    // notifier function to cause Memes  to be refreshed
    func refreshMemes(notification: NSNotification) {
        // set refresh notification to force repaint of screen next time it appears
        refresh = true
    }
    
    
    //
    // utilities
    

    
}

