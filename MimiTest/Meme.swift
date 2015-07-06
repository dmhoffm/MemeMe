//
//  Meme.swift
//  MimiTest
//
//  Created by David Hoffman on 6/28/15.
//  Copyright (c) 2015 dmhoffm. All rights reserved.
//
//
// Model for Meme object


import Foundation
import UIKit

// every Meme has a...
class Meme {
    var upperText: String?  //upper title
    var lowerText: String?  //lower title
    var image: UIImage!     //original image
    var memedImage: UIImage!//composite image including the titles
    
    // create meme if composite image is already available
    init(upperText: String?, lowerText: String?, image: UIImage!, memedImage: UIImage!) {
        self.upperText = upperText
        self.lowerText = lowerText
        self.image = image
        self.memedImage = memedImage
    }
    
}
