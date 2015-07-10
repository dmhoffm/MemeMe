//
//  MemeEditViewController.swift
//  MimiTest
//
//  Created by David Hoffman on 6/28/15.
//  Copyright (c) 2015 David Hoffman. All rights reserved.
//

import UIKit

class MemeEditViewController: UIViewController, UIImagePickerControllerDelegate,      UINavigationControllerDelegate, UITextFieldDelegate {

    // current saved meme array
    var memes: [Meme]! {
        get {
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            return appDelegate.memes
        }
        
    }
    
    var indexPath: NSIndexPath? //index of selected Meme for editing, (nil if a meme needs to be created from scratch)
    var sent: Bool = false     //meme has been sent or already exists
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
    
    @IBOutlet weak var camera: UIBarButtonItem! // camera button

    @IBOutlet weak var doneButton: UIBarButtonItem! //done editing button
    
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
                
                // let the parent controllers know of the change
                NSNotificationCenter.defaultCenter().postNotificationName("refreshMemes", object: nil)
                
                // indicate that a meme has been sent
                self.sent = true
                self.enableButtons()
            }
        }
        
        // now present the activity view
        self.presentViewController(controller, animated: true, completion: nil)
    }
    
    // "Cancel" button to return to parent controller
    @IBAction func returnToAlbumViewController(sender: UIBarButtonItem) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    // "Done" button to save edited meme (only enabled if meme is being edited)
    @IBAction func doneEditing(sender: UIBarButtonItem) {
        // only save meme if one was under edit
        if let row = self.indexPath?.row {
            let meme = self.save()  // construct the meme object from the current display
            
            // replace meme being edited with the current displayed meme
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            appDelegate.memes[row] = meme
            
            // let the parent controllers know of the change
            NSNotificationCenter.defaultCenter().postNotificationName("refreshMemes", object: nil)
        }
        
        // return to parent controller
        self.dismissViewControllerAnimated(true, completion: nil)
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
        
        // disable camera button if camera not available on device
        if UIImagePickerController.availableCaptureModesForCameraDevice(.Rear) == nil {
            self.camera.enabled = false
        }
        
        self.sent = false // initially no memes sent

    }
    
    // when view is about to appear, subscribe to keyboard notifications and optionally set up picture and titles
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // subscribe to keyboard notifications
        self.subscribeToKeyboardNotifications()
        
        // seed editing with selected meme if it's set and no image has been initialized yet
        let row =  self.indexPath?.row
        if row != nil && self.image.image == nil {
            self.sent = true //meme already exists
            self.image.image = self.memes[row!].image
            self.bottomText.text = self.memes[row!].lowerText
            self.topText.text = self.memes[row!].upperText
        } else {
            self.sent = false //no meme exists yet
        }
        
        // enable done and share button if conditions met
        enableButtons()
        
    }
    
    // when view is about to dissappear, unsubscribe to keyboard notifications
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        self.unsubscribeFromKeyboardNotifications()
    }
    
    // keyboard observer when keyboard is about to appear
    func keyboardWillShow(notification: NSNotification) {
        // disable share and done buttons whenever the keyboard is visable
        disableButtons()
        
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
        // reenable share and done buttons
        enableButtons()
        
        // if view has been shifted up, put it back
        if self.view.frame.origin.y < 0 {
            self.view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    //
    // image picker delegates
    
    // when is image is selected, remember it and dismiss controller
    func imagePickerController(picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject : AnyObject]!) {
        
        // resize original image from library (make sure titles are hidden)
        self.image.image = image
        self.bottomText.hidden = true
        self.topText.hidden = true
        var resizedImage = generateScreenImage() //same aspect ratio as memed image
        self.bottomText.hidden = false
        self.topText.hidden = false
        
        // save selected image in controller image property
        self.image.image = resizedImage
        
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
        // disable  button during editing
        disableButtons()
    }
    
    // editing completed
    func textFieldDidEndEditing(textField: UITextField) {
        self.currentTextFieldCGRect = nil
        // reenable buttons after editing
        enableButtons()
    }
    
    // hide keyboard when return is pressed
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        // reenable buttons after editing
        enableButtons()
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
    
    // generate a composite image by taking a snapshot from the screen
    func generateScreenImage() -> UIImage {
        
        // construct rect of image on screen
        var newRect = CGRect(origin: CGPoint(x: 0.0, y: self.navigationBar.frame.height), size:
            CGSize(width: self.image.frame.width, height: self.image.frame.height))

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        self.view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        var screenImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        // make sure image cropped
        screenImage = cropImage(screenImage, cropRect: newRect)
        return screenImage
    }
    
    // crop an image
    func cropImage(image: UIImage, cropRect: CGRect) -> UIImage {
        var cgImage = CGImageCreateWithImageInRect(image.CGImage, cropRect);
        var img = UIImage(CGImage: cgImage);
        return img!
    }
    
    // create a Meme from the current screen
    func save() -> Meme {
        // obtained memed composite
        var memedImage = generateScreenImage()
        
        // construct memed object and put in save memes
        var meme = Meme( upperText: self.topText.text, lowerText: self.bottomText.text, image: self.image.image, memedImage: memedImage)
        
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
    
    // enable share and done buttons if possible
    func enableButtons() {
        if self.image.image != nil {
            self.shareButtom.enabled = true //enable share if image exists
            if self.sent {
                self.doneButton.enabled = true //enable done if image exists and meme sent or exists
            }
        } else { //conditions not met to share or finish editing
            self.shareButtom.enabled = false
            self.doneButton.enabled = false
        }
    }
    
    // disable share and done buttons
    func disableButtons() {
        self.shareButtom.enabled = false
        self.doneButton.enabled = false
    }

}

