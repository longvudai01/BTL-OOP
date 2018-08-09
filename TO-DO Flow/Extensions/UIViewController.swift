//
//  UIViewController.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/22/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: - Alerts
    
    func showAlert(with title: String, and message: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        // Present Alert Controller
        present(alertController, animated: true, completion: nil)
    }
    
    func fixTextView(_ textView: UITextView) {
        let fixedWidth = textView.frame.width
        let newSize = textView.sizeThatFits( CGSize(width: fixedWidth, height: CGFloat.greatestFiniteMagnitude) )
        textView.frame.size = CGSize(width: max(fixedWidth, newSize.width), height: newSize.height)
    }
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    
}


