//
//  UITextView.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/27/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

extension UITextView {
    func strikeThrough(_ isFinished: Bool) {
        
        let attributedText = NSMutableAttributedString(string: self.text)
        
        if isFinished {
            attributedText.addAttributes([
                NSAttributedStringKey.strikethroughStyle : NSUnderlineStyle.styleSingle.rawValue,
                NSAttributedStringKey.strikethroughColor : UIColor.black,
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17),
                NSAttributedStringKey.foregroundColor: UIColor.gray
                ],
                                         range: NSMakeRange(0, attributedText.length))
        }
        else {
            attributedText.addAttributes([
                NSAttributedStringKey.font : UIFont.systemFont(ofSize: 17)
                ],
                                         range: NSMakeRange(0, attributedText.length))
        }
        self.attributedText = attributedText
        
        let transition = CATransition()
        transition.delegate = self as? CAAnimationDelegate
        transition.type = kCATransitionFromLeft
        transition.duration = 0.5
        
        
        self.layer.add(transition, forKey: "transition")
    }
}
