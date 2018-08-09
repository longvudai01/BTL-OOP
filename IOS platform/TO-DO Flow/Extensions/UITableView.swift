//
//  UITableView.swift
//  TO-DO Flow
//
//  Created by Dai Long on 7/27/18.
//  Copyright © 2018 Dai Long. All rights reserved.
//

import UIKit

extension UITableView {
    func indexPath(for view: UIView) -> IndexPath? {
        let location = view.convert(CGPoint.zero, to: self)
        return self.indexPathForRow(at: location)
    }
}
