//
//  MemeEditViewController.swift
//  MimiTest
//
//  Created by David Hoffman on 6/28/15.
//  Copyright (c) 2015 David Hoffman. All rights reserved.
//

import UIKit

class MemeEditViewController: UIViewController, UIImagePickerControllerDelegate,      UINavigationControllerDelegate, UITextFieldDelegate {

    var selectedMeme: Meme? //selected Meme from table/collection
    var currentTextFieldCGRect: CGRect? //CGRect of text field when editing started
    var pickController = UIImagePickerController()
    
    //
    // outlets
    
    @IBOutlet weak var image: UIImageView!      //main image on page
    
    @IBOutlet weak var topText: UITextField!    //top title
    
    @IBOutlet weak var bottomText: UITextField! //bottom title
    
    @IBOutlet weak var shareButtom: UIBarButtonItem!    //button for sharing the memed imaeg
    
    @IBOutlet weak var toolbar: UIToolbar!      //bottom toolbar (for hiding during image creation)
    
    @IBOutlet weak var navigationBar: UINavigationBar!  //top nav bar (for hiding during image creation)
    
    //
    // button actions
    
    // "Album" button
    @IBAction func pick(sender: UIBarButtonItem) {
        // pick photo from camera roll using image picker
        takePicFrom(UIImagePickerControllerSourceType.SavedPhotosAlbum)
    }

    // Camera button
    @IBAction func takePicture(sender: UIBarButtonItem) {
        // pick photo from camera roll using image picker
        takePicFrom(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    // Action button to share and/or save the current meme
    @IBAction func shareMeme(sender: UIBarButtonItem) {
        let meme = self.save()  // construct the meme object
        
        // construct the activity view controller and seed it with the memed image
        let controller = UIActivityViewController(activityItems: [meme.memedImage], applicationActivities: nil)
        
        // callback to save the meme if the activity was successful
        controller.completionWithItemsHandler = { activity, success, items, error in
            if success {
                // Save the new meme
                // Add it to the memes array in the Application Delegate
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.memes.append(meme)
            }
        }
        
        // now present the activity view
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // "Cancel" button to return to saved meme table and collection views
    @IBAction func returnToAlbumViewController(sender: UIBarButtonItem) {
        // get the Meme View Controller
        var controller: UITabBarController
        
        controller = self.storyboard?.instantiateViewControllerWithIdentifier("TabBarController") as! UITabBarController
        
        // bring up meme editor
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    //
    // call backs
    
    // when view is loaded, set up components
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        // set up delegate for pickController
        self.pickController.delegate = self
        
        // set up text fields
        setupText(self.topText)
        setupText(self.bottomText)
    }
    
    // when view is about to appear, subscribe to keyboard notifications and optionally set up picture and titles
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // subscribe to keyboard notifications
        self.subscribeToKeyboardNotifications()
        
        // seed editing with selected meme if it's set
        if self.selectedMeme != nil {
            self.image.image = self.selectedMeme?.image
            self.bottomText.text = self.selectedMeme?.lowerText
            self.topText.text = self.selectedMeme?.upperText
            self.selectedMeme = nil
        }
        
        // enable add share button if an image has been selected
        if self.image.image != nil {
            self.shareButtom.enabled = true
        } else {
            self.shareButtom.enabled = false
        }

    }
    
    // when view is about to dissappear, unsubscribe to keyboard notifications
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // keyboard observer when keyboard is about to appear
    func keyboardWillShow(notification: NSNotification) {
        // disable share button whenever the keyboard is visable
        self.shareButtom.enabled = false
        
        //if view hasn't already been shifted and the keyboard will obscure the textfield being edited, then shift the view up
        if let textCGRect = self.currentTextFieldCGRect {
            let textfieldBottomYp1 = textCGRect.origin.y + textCGRect.height
            let keyBoardHeight = getKeyboardHeight(notification)
            let viewBottomYp1AfterKeyboard = self.view.frame.height + self.view.frame.origin.y - keyBoardHeight
            if self.view.frame.origin.y >= 0 && textfieldBottomYp1 > viewBottomYp1AfterKeyboard {
                self.view.frame.origin.y -= keyBoardHeight
            }
            
        }
    }
    
    //keyboard observier when keyboard is about to disappear
    func keyboardWillHide(notification: NSNotification) {
        // reenable share button
        self.shareButtom.enabled = true
        
        // if view has been shifted up, put it back
        if self.view.frame.origin.y < 0 {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    
    
    
    //
    // image picker delegates
    
    // when is image is selected, remember it and dismiss controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        // save selected image in controller image property
        self.image.image = image
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // dismiss picker without saving any image
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //
    // text field delegates
    
    // editing started
    // clear out edits, remember position of textfield for possible reposition when keyboard shows
    func textFieldDidBeginEditing(textField: UITextField) {
        self.currentTextFieldCGRect = textField.frame
        textField.text == ""
    }
    
    // editing completed
    func textFieldDidEndEditing(textField: UITextField) {
        self.currentTextFieldCGRect = nil
    }
    
    // hide keyboard when return is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    //
    // utilities
    
    // goto photo pick controller
    func takePicFrom(source: UIImagePickerControllerSourceType) {
        // pick photo from source using image picker
        self.pickController.sourceType = source
        self.image.contentMode = UIViewContentMode.ScaleAspectFill
        self.presentViewController( self.pickController, animated: true, completion: nil)
    }
    
    // set up meme text field
    static let memeTextAttributes = [
        NSStrokeColorAttributeName : UIColor.blackColor(),
        NSForegroundColorAttributeName : UIColor.whiteColor(),
        NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSStrokeWidthAttributeName : -3.0 ]
    
    func setupText(field: UITextField) {
        field.delegate = self
        field.textAlignment = NSTextAlignment.Center
        field.adjustsFontSizeToFitWidth = true
        field.minimumFontSize = 20
        field.defaultTextAttributes = MemeEditViewController.memeTextAttributes
        field.clearsOnBeginEditing = true
        field.attributedPlaceholder = NSAttributedString(string: field.placeholder!,
            attributes:[NSForegroundColorAttributeName: UIColor.orangeColor()])
    }
    
    // generate a composite memed image by taking a snapshot from the screen (sans toolbar and navbar)
    func generateMemedImage() -> UIImage {
        
        // Hide toolbar and navbar
        self.toolbar.hidden = true
        self.navigationBar.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        // Show toolbar and navbar
        self.toolbar.hidden = false
        self.navigationBar.hidden = false
        
        return memedImage
    }
    
    // save a Meme
    func save() -> Meme {
        //Create the meme
        var meme = Meme( upperText: self.topText.text, lowerText: self.bottomText.text, image: self.image.image, memedImage: generateMemedImage())
        return meme
    }
    
    // subscribe keyboard notifications to call keyboardWillShow and keyboardWillHide
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:"    , name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:"    , name: UIKeyboardWillHideNotification, object: nil)
    }
    
    // unsubscribe keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name:
            UIKeyboardWillHideNotification, object: nil)
    }
    
    // determine keyboard size from notificaiton
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

}

