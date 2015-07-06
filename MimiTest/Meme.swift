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

class Meme {
    var upperText: String?
    var lowerText: String?
    var image: UIImage!
    var memedImage: UIImage!
    
    // create meme if composite image is already available
    init(upperText: String?, lowerText: String?, image: UIImage!, memedImage: UIImage!) {
        self.upperText = upperText
        self.lowerText = lowerText
        self.image = image
        self.memedImage = memedImage
    }
    
}
