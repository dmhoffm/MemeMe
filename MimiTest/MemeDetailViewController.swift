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
        if let row = self.indexPath?.row {
            if row < self.memes.count {
                // remove element from saved memes
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.memes.removeAtIndex(row)
                // let the parent controllers know of the change
                NSNotificationCenter.defaultCenter().postNotificationName("refreshMemes", object: nil)
                // return to previous view
                self.navigationController?.popViewControllerAnimated(true)
            }
        }
    }
    
    // Edit button
    @IBAction func editMeme(sender: UIBarButtonItem) {
        // get the Meme Edit View Controller
        let controller = self.storyboard?.instantiateViewControllerWithIdentifier("MemeEditViewController") as! MemeEditViewController
        //
        // seed with memed image of selected meme 
        if let row = self.indexPath?.row {
            controller.selectedMeme = self.memes[row]
        }
        
        // present meme editor
        self.presentViewController(controller, animated: true, completion: nil)
    }

    
    //
    // call backs
    
    // when view is loaded, set up components
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
    }
    
    // when view is about to appear,  set up picture
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // seed with memed image of selected meme if it's set
        if let row = self.indexPath?.row {
            self.image.image = self.memes[row].memedImage
        }
        
    }
    
    // when view is about to dissappear
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    
    //
    // utilities
    

    
}

